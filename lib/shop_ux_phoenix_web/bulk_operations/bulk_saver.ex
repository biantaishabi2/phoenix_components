defmodule ShopUxPhoenixWeb.BulkOperations.BulkSaver do
  @moduledoc """
  批量数据保存模块
  """

  @doc """
  批量保存数据
  """
  def save_batch(data, save_function, options \\ []) do
    start_time = System.monotonic_time(:millisecond)
    
    try do
      case data do
        [] -> {:ok, create_empty_result(start_time)}
        _ -> do_save_batch(data, save_function, options, start_time)
      end
    rescue
      error ->
        processing_time = System.monotonic_time(:millisecond) - start_time
        {:error, create_error_result(length(data), "保存过程异常: #{inspect(error)}", processing_time)}
    end
  end

  @doc """
  带验证的批量保存
  """
  def save_with_validation(data, validator_function, save_function, options \\ []) do
    start_time = System.monotonic_time(:millisecond)
    
    try do
      # 先验证数据
      {valid_data, errors} = Enum.reduce(data, {[], []}, fn item, {valid_acc, error_acc} ->
        case validator_function.(item) do
          :ok -> {[item | valid_acc], error_acc}
          {:error, reason} -> {valid_acc, [create_validation_error(item, reason) | error_acc]}
        end
      end)
      
      # 保存有效数据
      case valid_data do
        [] ->
          processing_time = System.monotonic_time(:millisecond) - start_time
          result = %{
            total_rows: length(data),
            success_count: 0,
            error_count: length(errors),
            saved_data: [],
            errors: errors,
            processing_time: processing_time
          }
          {:error, result}
        
        _ ->
          case do_save_batch(Enum.reverse(valid_data), save_function, options, start_time) do
            {:ok, save_result} ->
              # 合并验证错误
              final_result = Map.put(save_result, :errors, save_result.errors ++ errors)
              |> Map.put(:error_count, save_result.error_count + length(errors))
              |> Map.put(:total_rows, length(data))
              
              determine_result_status(final_result)
            
            result -> result
          end
      end
    rescue
      error ->
        processing_time = System.monotonic_time(:millisecond) - start_time
        {:error, create_error_result(length(data), "验证过程异常: #{inspect(error)}", processing_time)}
    end
  end

  # 私有函数

  defp do_save_batch(data, save_function, options, start_time) do
    batch_size = Keyword.get(options, :batch_size, 1000)
    transaction = Keyword.get(options, :transaction, false)
    error_handler = Keyword.get(options, :error_handler, &default_error_handler/2)
    timeout = Keyword.get(options, :timeout, :infinity)
    
    if transaction do
      save_with_transaction(data, save_function, batch_size, error_handler, timeout, start_time)
    else
      save_without_transaction(data, save_function, batch_size, error_handler, timeout, start_time)
    end
  end

  defp save_without_transaction(data, save_function, batch_size, error_handler, timeout, start_time) do
    results = data
    |> Enum.chunk_every(batch_size)
    |> Enum.flat_map(fn batch ->
      case execute_with_timeout(save_function, batch, timeout) do
        {:ok, batch_results} -> batch_results
        {:error, reason} ->
          # 如果整个批次失败，为每个项目创建错误
          Enum.map(batch, fn _item ->
            {:error, reason}
          end)
      end
    end)
    
    # 处理结果
    {saved_data, errors} = process_save_results(results, data, error_handler)
    
    processing_time = System.monotonic_time(:millisecond) - start_time
    
    result = %{
      total_rows: length(data),
      success_count: length(saved_data),
      error_count: length(errors),
      saved_data: saved_data,
      errors: errors,
      processing_time: processing_time
    }
    
    determine_result_status(result)
  end

  defp save_with_transaction(data, save_function, batch_size, error_handler, timeout, start_time) do
    # 事务模式：如果任何批次失败，回滚所有操作
    try do
      all_results = data
      |> Enum.chunk_every(batch_size)
      |> Enum.flat_map(fn batch ->
        case execute_with_timeout(save_function, batch, timeout) do
          {:ok, batch_results} ->
            # 检查批次中是否有失败项
            if Enum.any?(batch_results, &match?({:error, _}, &1)) do
              throw({:transaction_error, "批次中包含失败项"})
            else
              batch_results
            end
          
          {:error, reason} ->
            throw({:transaction_error, reason})
        end
      end)
      
      # 如果到这里，说明所有保存都成功
      processing_time = System.monotonic_time(:millisecond) - start_time
      
      saved_data = Enum.map(all_results, fn {:ok, item} -> item end)
      
      result = %{
        total_rows: length(data),
        success_count: length(saved_data),
        error_count: 0,
        saved_data: saved_data,
        errors: [],
        processing_time: processing_time
      }
      
      {:ok, result}
      
    catch
      {:transaction_error, reason} ->
        # 事务回滚：所有操作都视为失败
        processing_time = System.monotonic_time(:millisecond) - start_time
        
        errors = Enum.with_index(data, 1) |> Enum.map(fn {item, index} ->
          error_handler.(reason, item) |> Map.put(:index, index)
        end)
        
        result = %{
          total_rows: length(data),
          success_count: 0,
          error_count: length(errors),
          saved_data: [],
          errors: errors,
          processing_time: processing_time
        }
        
        {:error, result}
    end
  end

  defp execute_with_timeout(function, data, timeout) do
    if timeout == :infinity do
      {:ok, function.(data)}
    else
      task = Task.async(fn -> function.(data) end)
      
      case Task.yield(task, timeout) || Task.shutdown(task) do
        {:ok, result} -> {:ok, result}
        nil -> {:error, "操作超时"}
      end
    end
  end

  defp process_save_results(results, original_data, error_handler) do
    results
    |> Enum.zip(original_data)
    |> Enum.with_index(1)
    |> Enum.reduce({[], []}, fn {{result, original_item}, index}, {saved_acc, error_acc} ->
      case result do
        {:ok, saved_item} ->
          {[saved_item | saved_acc], error_acc}
        
        {:error, error_info} ->
          error = error_handler.(error_info, original_item)
          |> Map.put(:index, index)
          
          {saved_acc, [error | error_acc]}
      end
    end)
    |> then(fn {saved, errors} ->
      {Enum.reverse(saved), Enum.reverse(errors)}
    end)
  end

  defp default_error_handler(error_info, row_data) do
    %{
      row_data: row_data,
      message: to_string(error_info)
    }
  end

  defp create_validation_error(item, reason) do
    %{
      row_data: item,
      message: reason,
      type: :validation_error
    }
  end

  defp create_empty_result(start_time) do
    processing_time = System.monotonic_time(:millisecond) - start_time
    
    %{
      total_rows: 0,
      success_count: 0,
      error_count: 0,
      saved_data: [],
      errors: [],
      processing_time: processing_time
    }
  end

  defp create_error_result(total_rows, error_message, processing_time) do
    %{
      total_rows: total_rows,
      success_count: 0,
      error_count: total_rows,
      saved_data: [],
      errors: [%{message: error_message}],
      processing_time: processing_time
    }
  end

  defp determine_result_status(result) do
    cond do
      result.error_count == 0 -> {:ok, result}
      result.success_count == 0 -> {:error, result}
      true -> {:partial, result}
    end
  end
end
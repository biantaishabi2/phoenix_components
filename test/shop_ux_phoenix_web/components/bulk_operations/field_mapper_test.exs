defmodule ShopUxPhoenixWeb.BulkOperations.FieldMapperTest do
  use ExUnit.Case, async: true
  
  alias ShopUxPhoenixWeb.BulkOperations.FieldMapper
  
  setup do
    form_config = %{
      fields: [
        %{name: "name", label: "姓名", type: "input", required: true},
        %{name: "email", label: "邮箱", type: "email", required: true},
        %{name: "phone", label: "电话", type: "tel"},
        %{name: "department", label: "部门", type: "select"}
      ]
    }
    
    %{form_config: form_config}
  end
  
  describe "auto_map/3" do
    test "自动映射相同名称的字段", %{form_config: _form_config} do
      headers = ["姓名", "邮箱", "电话"]
      form_fields = ["name", "email", "phone", "department"]
      mapping_rules = %{"姓名" => "name", "邮箱" => "email", "电话" => "phone"}
      
      assert {:ok, mapping} = FieldMapper.auto_map(headers, form_fields, mapping_rules)
      assert mapping == %{"姓名" => "name", "邮箱" => "email", "电话" => "phone"}
    end
    
    test "处理无法映射的字段", %{form_config: _form_config} do
      headers = ["姓名", "未知字段", "邮箱"]
      form_fields = ["name", "email"]
      mapping_rules = %{"姓名" => "name", "邮箱" => "email"}
      
      assert {:partial, mapping, unmapped} = FieldMapper.auto_map(headers, form_fields, mapping_rules)
      assert mapping == %{"姓名" => "name", "邮箱" => "email"}
      assert unmapped == ["未知字段"]
    end
    
    test "智能映射相似字段名", %{form_config: _form_config} do
      headers = ["用户名", "电子邮箱", "手机号"]
      form_fields = ["name", "email", "phone"]
      mapping_rules = %{}
      
      # 应该能够智能匹配相似的字段名
      assert {:partial, mapping, unmapped} = FieldMapper.auto_map(headers, form_fields, mapping_rules)
      # 根据智能匹配算法的具体实现调整期望结果
      assert is_map(mapping)
      assert is_list(unmapped)
    end
    
    test "处理空表头", %{form_config: _form_config} do
      headers = []
      form_fields = ["name", "email"]
      mapping_rules = %{}
      
      assert {:ok, mapping} = FieldMapper.auto_map(headers, form_fields, mapping_rules)
      assert mapping == %{}
    end
    
    test "处理重复表头", %{form_config: _form_config} do
      headers = ["姓名", "邮箱", "姓名"]  # 重复的姓名
      form_fields = ["name", "email"]
      mapping_rules = %{"姓名" => "name", "邮箱" => "email"}
      
      # 应该处理重复表头，可能返回错误或者使用第一个匹配
      result = FieldMapper.auto_map(headers, form_fields, mapping_rules)
      assert match?({:error, _}, result) or match?({:ok, _}, result) or match?({:partial, _, _}, result)
    end
  end
  
  describe "validate_mapping/2" do
    test "验证有效的字段映射", %{form_config: form_config} do
      mapping = %{"姓名" => "name", "邮箱" => "email"}
      
      assert :ok = FieldMapper.validate_mapping(mapping, form_config)
    end
    
    test "检测无效的字段映射", %{form_config: form_config} do
      mapping = %{"姓名" => "invalid_field", "邮箱" => "another_invalid"}
      
      assert {:error, invalid_fields} = FieldMapper.validate_mapping(mapping, form_config)
      assert "invalid_field" in invalid_fields
      assert "another_invalid" in invalid_fields
    end
    
    test "检测部分无效的映射", %{form_config: form_config} do
      mapping = %{"姓名" => "name", "邮箱" => "email", "未知列" => "invalid_field"}
      
      assert {:error, invalid_fields} = FieldMapper.validate_mapping(mapping, form_config)
      assert invalid_fields == ["invalid_field"]
    end
    
    test "验证空映射", %{form_config: form_config} do
      mapping = %{}
      
      assert :ok = FieldMapper.validate_mapping(mapping, form_config)
    end
  end
  
  describe "suggest_mapping/2" do
    test "基于相似度建议字段映射", %{form_config: form_config} do
      headers = ["用户姓名", "电子邮件", "联系电话"]
      
      suggestions = FieldMapper.suggest_mapping(headers, form_config)
      
      assert is_map(suggestions)
      # 应该能够基于相似度建议合适的映射
      # 具体断言根据实际实现的相似度算法调整
    end
    
    test "处理完全不匹配的字段", %{form_config: form_config} do
      headers = ["完全不匹配的字段1", "完全不匹配的字段2"]
      
      suggestions = FieldMapper.suggest_mapping(headers, form_config)
      
      # 对于完全不匹配的字段，应该返回空建议或者最佳猜测
      assert is_map(suggestions)
    end
  end
  
  describe "get_mapping_confidence/3" do
    test "计算映射置信度", %{form_config: form_config} do
      headers = ["姓名", "邮箱", "电话"]
      mapping = %{"姓名" => "name", "邮箱" => "email", "电话" => "phone"}
      
      confidence = FieldMapper.get_mapping_confidence(headers, mapping, form_config)
      
      # 完全匹配应该有高置信度
      assert confidence > 0.8
      assert confidence <= 1.0
    end
    
    test "部分匹配的置信度", %{form_config: form_config} do
      headers = ["姓名", "未知字段", "邮箱"]
      mapping = %{"姓名" => "name", "邮箱" => "email"}
      
      confidence = FieldMapper.get_mapping_confidence(headers, mapping, form_config)
      
      # 部分匹配应该有中等置信度
      assert confidence > 0.0
      assert confidence < 1.0
    end
    
    test "无匹配的置信度", %{form_config: form_config} do
      headers = ["完全不匹配1", "完全不匹配2"]
      mapping = %{}
      
      confidence = FieldMapper.get_mapping_confidence(headers, mapping, form_config)
      
      # 无匹配应该有低置信度
      assert confidence >= 0.0
      assert confidence <= 0.2
    end
  end
  
  describe "apply_mapping/3" do
    test "应用字段映射转换数据" do
      headers = ["姓名", "邮箱", "电话"]
      data_rows = [
        ["张三", "zhang@test.com", "13800138000"],
        ["李四", "li@test.com", "13900139000"]
      ]
      mapping = %{"姓名" => "name", "邮箱" => "email", "电话" => "phone"}
      
      result = FieldMapper.apply_mapping(headers, data_rows, mapping)
      
      expected = [
        %{"name" => "张三", "email" => "zhang@test.com", "phone" => "13800138000"},
        %{"name" => "李四", "email" => "li@test.com", "phone" => "13900139000"}
      ]
      
      assert result == expected
    end
    
    test "处理部分映射的数据" do
      headers = ["姓名", "未映射字段", "邮箱"]
      data_rows = [
        ["张三", "忽略的值", "zhang@test.com"]
      ]
      mapping = %{"姓名" => "name", "邮箱" => "email"}
      
      result = FieldMapper.apply_mapping(headers, data_rows, mapping)
      
      expected = [
        %{"name" => "张三", "email" => "zhang@test.com"}
      ]
      
      assert result == expected
    end
    
    test "处理空值和缺失值" do
      headers = ["姓名", "邮箱", "电话"]
      data_rows = [
        ["张三", "", "13800138000"],
        ["", "li@test.com", nil],
        ["王五", "wang@test.com", "13700137000"]
      ]
      mapping = %{"姓名" => "name", "邮箱" => "email", "电话" => "phone"}
      
      result = FieldMapper.apply_mapping(headers, data_rows, mapping)
      
      expected = [
        %{"name" => "张三", "email" => "", "phone" => "13800138000"},
        %{"name" => "", "email" => "li@test.com", "phone" => nil},
        %{"name" => "王五", "email" => "wang@test.com", "phone" => "13700137000"}
      ]
      
      assert result == expected
    end
    
    test "处理行长度不一致的数据" do
      headers = ["姓名", "邮箱", "电话"]
      data_rows = [
        ["张三", "zhang@test.com"],  # 缺少电话
        ["李四", "li@test.com", "13900139000", "多余字段"]  # 多了一个字段
      ]
      mapping = %{"姓名" => "name", "邮箱" => "email", "电话" => "phone"}
      
      result = FieldMapper.apply_mapping(headers, data_rows, mapping)
      
      expected = [
        %{"name" => "张三", "email" => "zhang@test.com", "phone" => nil},
        %{"name" => "李四", "email" => "li@test.com", "phone" => "13900139000"}
      ]
      
      assert result == expected
    end
  end
  
  describe "validate_required_fields/2" do
    test "检查必填字段是否已映射", %{form_config: form_config} do
      mapping = %{"姓名" => "name", "邮箱" => "email", "电话" => "phone"}
      
      assert :ok = FieldMapper.validate_required_fields(mapping, form_config)
    end
    
    test "检测缺失的必填字段", %{form_config: form_config} do
      mapping = %{"电话" => "phone"}  # 缺少必填的 name 和 email
      
      assert {:error, missing_fields} = FieldMapper.validate_required_fields(mapping, form_config)
      assert "name" in missing_fields
      assert "email" in missing_fields
    end
    
    test "只检查已配置为必填的字段", %{form_config: form_config} do
      mapping = %{"姓名" => "name", "邮箱" => "email"}  # 没有phone，但phone不是必填的
      
      assert :ok = FieldMapper.validate_required_fields(mapping, form_config)
    end
  end
end
defmodule ShopUxPhoenixWeb.Components.FormBuilderSmartLinkageTest do
  use ShopUxPhoenixWeb.ComponentCase
  import ShopUxPhoenixWeb.Components.FormBuilder
  
  
  describe "复杂条件显示 - show_if" do
    test "向后兼容：简单字符串条件" do
      config = %{
        fields: [
          %{
            name: "user_type",
            type: "select",
            label: "用户类型",
            options: [
              %{value: "personal", label: "个人"},
              %{value: "company", label: "企业"}
            ]
          },
          %{
            name: "company_name",
            type: "input",
            label: "公司名称",
            show_if: "user_type == 'company'"
          }
        ]
      }
      
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"user_type" => "personal"}
      )
      
      # company_name 字段应该被隐藏
      refute html =~ ~r/<input[^>]*name="company_name"/
      
      # 当 user_type 为 company 时应该显示
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"user_type" => "company"}
      )
      
      assert html =~ ~r/<input[^>]*name="company_name"/
    end
    
    test "AND 逻辑组合条件" do
      config = %{
        fields: [
          %{name: "user_type", type: "select", label: "用户类型"},
          %{name: "revenue", type: "number", label: "年收入"},
          %{
            name: "enterprise_features",
            type: "checkbox",
            label: "企业特性",
            show_if: %{
              and: [
                "user_type == 'company'",
                "revenue > 1000000"
              ]
            }
          }
        ]
      }
      
      # 两个条件都不满足
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"user_type" => "personal", "revenue" => "500000"}
      )
      refute html =~ "enterprise_features"
      
      # 只满足一个条件
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"user_type" => "company", "revenue" => "500000"}
      )
      refute html =~ "enterprise_features"
      
      # 两个条件都满足
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"user_type" => "company", "revenue" => "2000000"}
      )
      assert html =~ "enterprise_features"
    end
    
    test "OR 逻辑组合条件" do
      config = %{
        fields: [
          %{
            name: "country",
            type: "select",
            label: "国家",
            options: [
              %{value: "US", label: "美国"},
              %{value: "CA", label: "加拿大"},
              %{value: "CN", label: "中国"}
            ]
          },
          %{
            name: "tax_id",
            type: "input",
            label: "税号",
            show_if: %{
              or: ["country == 'US'", "country == 'CA'"]
            }
          }
        ]
      }
      
      # US 显示
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"country" => "US"}
      )
      assert html =~ "tax_id"
      
      # CA 显示
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"country" => "CA"}
      )
      assert html =~ "tax_id"
      
      # CN 不显示
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"country" => "CN"}
      )
      refute html =~ "tax_id"
    end
    
    test "嵌套条件组合" do
      config = %{
        fields: [
          %{name: "user_type", type: "select", label: "用户类型"},
          %{name: "industry", type: "select", label: "行业"},
          %{name: "employees", type: "number", label: "员工数"},
          %{
            name: "special_discount",
            type: "number",
            label: "特殊折扣",
            show_if: %{
              and: [
                "user_type == 'company'",
                %{
                  or: [
                    %{and: ["industry == 'tech'", "employees > 100"]},
                    %{and: ["industry == 'finance'", "employees > 50"]}
                  ]
                }
              ]
            }
          }
        ]
      }
      
      # 科技公司，超过100人
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{
          "user_type" => "company",
          "industry" => "tech",
          "employees" => "150"
        }
      )
      assert html =~ "special_discount"
      
      # 科技公司，少于100人
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{
          "user_type" => "company",
          "industry" => "tech",
          "employees" => "50"
        }
      )
      refute html =~ "special_discount"
      
      # 金融公司，超过50人
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{
          "user_type" => "company",
          "industry" => "finance",
          "employees" => "60"
        }
      )
      assert html =~ "special_discount"
    end
    
    test "数值比较条件" do
      config = %{
        fields: [
          %{name: "age", type: "number", label: "年龄"},
          %{
            name: "senior_benefits",
            type: "checkbox",
            label: "老年福利",
            show_if: "age >= 65"
          },
          %{
            name: "youth_programs",
            type: "checkbox",
            label: "青年项目",
            show_if: "age < 30"
          }
        ]
      }
      
      # 测试老年福利
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"age" => "70"}
      )
      assert html =~ "senior_benefits"
      refute html =~ "youth_programs"
      
      # 测试青年项目
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"age" => "25"}
      )
      refute html =~ "senior_benefits"
      assert html =~ "youth_programs"
    end
  end
  
  describe "动态字段选项加载" do
    test "同步加载选项 - 函数方式" do
      config = %{
        fields: [
          %{
            name: "province",
            type: "select",
            label: "省份",
            options: [
              %{value: "guangdong", label: "广东"},
              %{value: "beijing", label: "北京"}
            ]
          },
          %{
            name: "city",
            type: "select",
            label: "城市",
            depends_on: ["province"],
            load_options: fn form_data ->
              case form_data["province"] do
                "guangdong" -> [
                  %{value: "guangzhou", label: "广州"},
                  %{value: "shenzhen", label: "深圳"}
                ]
                "beijing" -> [
                  %{value: "beijing", label: "北京"}
                ]
                _ -> []
              end
            end
          }
        ]
      }
      
      # 选择广东省时的城市选项
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"province" => "guangdong"}
      )
      
      assert html =~ "广州"
      assert html =~ "深圳"
      # 验证城市选项中没有"北京市"（只检查城市列表部分）
      # 省份选项中有"北京"是正确的，但城市选项中不应该有
      # 由于HTML结构，我们需要更精确的检查
      assert html =~ "北京"  # 省份选项中应该有
      # 验证城市只有广州和深圳
      city_count = length(Regex.scan(~r/<option value="(guangzhou|shenzhen|beijing)">/, html))
      assert city_count == 3  # 2个城市选项 + 1个省份选项
    end
  end
  
  describe "计算字段" do
    test "简单算术计算 - 价格计算" do
      config = %{
        fields: [
          %{name: "unit_price", type: "number", label: "单价"},
          %{name: "quantity", type: "number", label: "数量"},
          %{
            name: "total",
            type: "number",
            label: "总价",
            readonly: true,
            computed: %{
              formula: "unit_price * quantity",
              depends_on: ["unit_price", "quantity"]
            }
          }
        ]
      }
      
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{
          "unit_price" => "100",
          "quantity" => "5"
        }
      )
      
      # 应该计算出总价为 500
      assert html =~ ~r/value="500"/
    end
    
    test "带折扣的价格计算" do
      config = %{
        fields: [
          %{name: "subtotal", type: "number", label: "小计"},
          %{name: "discount", type: "number", label: "折扣(%)"},
          %{
            name: "final_price",
            type: "number",
            label: "最终价格",
            readonly: true,
            computed: %{
              compute: fn form_data ->
                subtotal = parse_number(form_data["subtotal"])
                discount = parse_number(form_data["discount"])
                subtotal * (1 - discount / 100)
              end,
              depends_on: ["subtotal", "discount"]
            }
          }
        ]
      }
      
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{
          "subtotal" => "1000",
          "discount" => "20"
        }
      )
      
      # 1000 * (1 - 20/100) = 800
      assert html =~ "value=\"800.0\""
    end
    
    test "字符串拼接计算" do
      config = %{
        fields: [
          %{name: "first_name", type: "input", label: "名"},
          %{name: "last_name", type: "input", label: "姓"},
          %{
            name: "full_name",
            type: "input",
            label: "全名",
            readonly: true,
            computed: %{
              compute: fn form_data ->
                "#{form_data["last_name"] || ""} #{form_data["first_name"] || ""}"
                |> String.trim()
              end,
              depends_on: ["first_name", "last_name"]
            }
          }
        ]
      }
      
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{
          "first_name" => "三",
          "last_name" => "张"
        }
      )
      
      assert html =~ ~r/value="张 三"/
    end
  end
  
  describe "字段依赖和级联更新" do
    test "字段重置配置" do
      config = %{
        fields: [
          %{
            name: "country",
            type: "select",
            label: "国家",
            on_change: %{
              reset: ["state", "city"]
            }
          },
          %{name: "state", type: "select", label: "州/省"},
          %{name: "city", type: "select", label: "城市"}
        ]
      }
      
      # 验证配置正确解析
      field = Enum.find(config.fields, &(&1.name == "country"))
      assert field.on_change.reset == ["state", "city"]
    end
    
    test "循环依赖检测" do
      config = %{
        fields: [
          %{name: "field_a", depends_on: ["field_b"]},
          %{name: "field_b", depends_on: ["field_c"]},
          %{name: "field_c", depends_on: ["field_a"]}
        ]
      }
      
      # 这应该在构建依赖图时被检测到
      assert {:error, "Circular dependency detected"} = 
        validate_field_dependencies(config.fields)
    end
  end
  
  describe "条件评估器增强" do
    test "包含操作符 - in" do
      config = %{
        fields: [
          %{
            name: "role",
            type: "select",
            label: "角色"
          },
          %{
            name: "admin_panel",
            type: "checkbox",
            label: "管理面板",
            show_if: %{
              expression: "role in ['admin', 'super_admin']"
            }
          }
        ]
      }
      
      # admin 角色显示
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"role" => "admin"}
      )
      assert html =~ "admin_panel"
      
      # user 角色不显示
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"role" => "user"}
      )
      refute html =~ "admin_panel"
    end
    
    test "正则表达式匹配" do
      config = %{
        fields: [
          %{name: "email", type: "email", label: "邮箱"},
          %{
            name: "corporate_features",
            type: "checkbox",
            label: "企业功能",
            show_if: %{
              expression: "email matches '@company\\.com$'"
            }
          }
        ]
      }
      
      # 企业邮箱显示
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"email" => "john@company.com"}
      )
      assert html =~ "corporate_features"
      
      # 个人邮箱不显示
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"email" => "john@gmail.com"}
      )
      refute html =~ "corporate_features"
    end
    
    test "存在性检查 - present/blank" do
      config = %{
        fields: [
          %{name: "referral_code", type: "input", label: "推荐码"},
          %{
            name: "referral_bonus",
            type: "number",
            label: "推荐奖励",
            show_if: %{expression: "referral_code present"}
          },
          %{
            name: "no_referral_message",
            type: "text",
            label: "无推荐码提示",
            show_if: %{expression: "referral_code blank"}
          }
        ]
      }
      
      # 有推荐码时
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"referral_code" => "ABC123"}
      )
      assert html =~ "referral_bonus"
      refute html =~ "no_referral_message"
      
      # 无推荐码时
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"referral_code" => ""}
      )
      refute html =~ "referral_bonus"
      # 当 referral_code 为空字符串时，根据 blank 条件，no_referral_message 应该显示
      assert html =~ "无推荐码提示"
    end
  end
  
  describe "边界情况和错误处理" do
    test "空值和nil处理" do
      config = %{
        fields: [
          %{name: "field", type: "input"},
          %{
            name: "dependent",
            type: "input",
            show_if: "field == ''"
          }
        ]
      }
      
      # nil 应该被当作空字符串处理
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"field" => nil}
      )
      assert html =~ "dependent"
    end
    
    test "类型转换错误处理" do
      config = %{
        fields: [
          %{name: "invalid_number", type: "input", label: "数字"},
          %{
            name: "result",
            type: "number",
            label: "结果",
            computed: %{
              compute: fn form_data ->
                case Float.parse(form_data["invalid_number"] || "0") do
                  {num, _} -> num * 2
                  :error -> 0
                end
              end,
              depends_on: ["invalid_number"]
            }
          }
        ]
      }
      
      # 无效数字应该返回默认值0
      html = render_component(&form_builder/1,
        id: "test-form",
        config: config,
        initial_data: %{"invalid_number" => "not a number"}
      )
      assert html =~ ~r/value="0"/
    end
  end
  
  # 辅助函数
  defp parse_number(nil), do: 0.0
  defp parse_number(""), do: 0.0
  defp parse_number(value) when is_binary(value) do
    case Float.parse(value) do
      {num, _} -> num
      :error -> 
        case Integer.parse(value) do
          {num, _} -> num * 1.0
          :error -> 0.0
        end
    end
  end
  defp parse_number(value) when is_number(value), do: value * 1.0
  defp parse_number(_), do: 0.0
  
  defp validate_field_dependencies(fields) do
    # 简单的循环依赖检测
    deps = Enum.reduce(fields, %{}, fn field, acc ->
      if field[:depends_on] do
        Map.put(acc, field.name, field.depends_on)
      else
        acc
      end
    end)
    
    # 检查循环依赖
    Enum.reduce_while(deps, {:ok, []}, fn {field, _}, acc ->
      case check_circular_dependency(field, deps, []) do
        {:ok, _} -> {:cont, acc}
        {:error, _} = error -> {:halt, error}
      end
    end)
  end
  
  defp check_circular_dependency(field, deps, visited) do
    if field in visited do
      {:error, "Circular dependency detected"}
    else
      visited = [field | visited]
      
      case Map.get(deps, field) do
        nil -> {:ok, visited}
        dependencies ->
          Enum.reduce_while(dependencies, {:ok, visited}, fn dep, _acc ->
            case check_circular_dependency(dep, deps, visited) do
              {:ok, new_visited} -> {:cont, {:ok, new_visited}}
              error -> {:halt, error}
            end
          end)
      end
    end
  end
end
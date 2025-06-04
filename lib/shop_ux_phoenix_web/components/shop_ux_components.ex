defmodule ShopUxPhoenixWeb.ShopUxComponents do
  @moduledoc """
  自定义组件库 - 补充Petal Components缺失的组件
  统一导入所有自定义组件
  """
  
  # 每个组件在自己的文件中定义
  # 这里只是统一导入，方便使用
  defmacro __using__(_) do
    quote do
      import ShopUxPhoenixWeb.Components.Table
      import ShopUxPhoenixWeb.Components.Select
      import ShopUxPhoenixWeb.Components.Tag
      import ShopUxPhoenixWeb.Components.Statistic
      import ShopUxPhoenixWeb.Components.Steps
      import ShopUxPhoenixWeb.Components.DatePicker
      import ShopUxPhoenixWeb.Components.RangePicker
      import ShopUxPhoenixWeb.Components.Cascader
      import ShopUxPhoenixWeb.Components.TreeSelect
      import ShopUxPhoenixWeb.Components.InputNumber
      import ShopUxPhoenixWeb.Components.Switch
      import ShopUxPhoenixWeb.Components.Tabs
      import ShopUxPhoenixWeb.Components.Dropdown
      import ShopUxPhoenixWeb.Components.Progress
      import ShopUxPhoenixWeb.Components.Tooltip
      import ShopUxPhoenixWeb.Components.FilterForm
      import ShopUxPhoenixWeb.Components.SearchableSelect
      import ShopUxPhoenixWeb.Components.Breadcrumb
      import ShopUxPhoenixWeb.Components.Card
      import ShopUxPhoenixWeb.Components.StatusBadge
      import ShopUxPhoenixWeb.Components.ActionButtons
      import ShopUxPhoenixWeb.Components.AddressSelector
      import ShopUxPhoenixWeb.Components.Timeline
      import ShopUxPhoenixWeb.Components.FormBuilder
      import ShopUxPhoenixWeb.Components.MediaUpload
      
      # Business Components
      import ShopUxPhoenixWeb.BusinessComponents.AppLayout
    end
  end
end
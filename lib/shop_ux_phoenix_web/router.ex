defmodule ShopUxPhoenixWeb.Router do
  use ShopUxPhoenixWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ShopUxPhoenixWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ShopUxPhoenixWeb.SessionManager
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShopUxPhoenixWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/components", ComponentIndexController, :index
    live "/components-demo", ComponentsDemoLive
    
    # 新的组件展示页面
    live "/components/showcase", ComponentShowcaseLive
    
    # Component demo routes
    live "/components/table", TableDemoLive
    live "/components/date_picker", DatePickerDemoLive
    live "/components/select", SelectDemoLive
    live "/components/range_picker", RangePickerDemoLive
    live "/components/cascader", CascaderDemoLive
    live "/components/tree_select", TreeSelectDemoLive
    live "/components/steps", StepsDemoLive
    live "/components/statistic", StatisticDemoLive
    live "/components/input_number", InputNumberDemoLive
    live "/components/switch", SwitchDemoLive
    live "/components/tabs", TabsDemoLive
    live "/components/dropdown", DropdownDemoLive
    live "/components/progress", ProgressDemoLive
    live "/components/tooltip", TooltipDemoLive
    live "/components/app_layout", AppLayoutDemoLive
    live "/components/filter_form", FilterFormDemoLive
    live "/components/searchable_select", SearchableSelectDemoLive
    live "/components/breadcrumb", BreadcrumbDemoLive
    live "/components/card", CardDemoLive
    live "/components/status_badge", StatusBadgeDemoLive
    live "/components/action_buttons", ActionButtonsDemoLive
    live "/components/address_selector", AddressSelectorDemoLive
    live "/components/timeline", TimelineDemoLive
    live "/components/form_builder", FormBuilderDemoLive
    live "/components/media_upload", MediaUploadDemoLive
    live "/components/tag", ComponentsDemoLive
    
    # 独立 demo 页面路由（用于新标签页打开）
    scope "/demo", as: :demo do
      live "/table", TableDemoLive
      live "/form_builder", FormBuilderDemoLive
      live "/select", SelectDemoLive
      live "/searchable_select", SearchableSelectDemoLive
      live "/tree_select", TreeSelectDemoLive
      live "/cascader", CascaderDemoLive
      live "/date_picker", DatePickerDemoLive
      live "/range_picker", RangePickerDemoLive
      live "/input_number", InputNumberDemoLive
      live "/switch", SwitchDemoLive
      live "/address_selector", AddressSelectorDemoLive
      live "/media_upload", MediaUploadDemoLive
      live "/card", CardDemoLive
      live "/statistic", StatisticDemoLive
      live "/timeline", TimelineDemoLive
      live "/progress", ProgressDemoLive
      live "/app_layout", AppLayoutDemoLive
      live "/tabs", TabsDemoLive
      live "/steps", StepsDemoLive
      live "/breadcrumb", BreadcrumbDemoLive
      live "/filter_form", FilterFormDemoLive
      live "/action_buttons", ActionButtonsDemoLive
      live "/dropdown", DropdownDemoLive
      live "/tooltip", TooltipDemoLive
      live "/status_badge", StatusBadgeDemoLive
    end
    
    # Test route for component testing
    if Mix.env() == :test do
      live "/test/table", TableDemoLive
      live "/test/date-picker", DatePickerDemoLive
      live "/test/select", SelectDemoLive
      live "/test/range-picker", RangePickerDemoLive
      live "/test/cascader", CascaderDemoLive
      live "/test/tree-select", TreeSelectDemoLive
      live "/test/steps", StepsDemoLive
      live "/test/statistic", StatisticDemoLive
      live "/test_form", TestFormLive
      live "/form-builder/bulk-import", BulkImportLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShopUxPhoenixWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:shop_ux_phoenix, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ShopUxPhoenixWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

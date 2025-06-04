defmodule ShopUxPhoenixWeb.ConditionalFormTest do
  use ShopUxPhoenixWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  defmodule TestLive do
    use ShopUxPhoenixWeb, :live_view
    alias ShopUxPhoenixWeb.Components.FormBuilder

    def mount(_params, _session, socket) do
      form_config = %{
        fields: [
          %{
            name: "user_type",
            label: "User Type",
            type: "radio",
            options: [
              %{label: "Personal", value: "personal"},
              %{label: "Company", value: "company"}
            ],
            value: "personal"
          },
          %{
            name: "company_name",
            label: "Company Name",
            type: "input",
            show_if: "user_type == 'company'"
          }
        ]
      }

      form_data = %{user_type: "personal"}

      {:ok, assign(socket, 
        form_config: form_config, 
        form_data: form_data,
        errors: %{}
      )}
    end

    def render(assigns) do
      ~H"""
      <div class="p-4">
        <FormBuilder.form_builder
          id="test_form"
          config={@form_config}
          initial_data={@form_data}
          on_change="validate"
          on_submit="submit"
        />
      </div>
      """
    end

    def handle_event("validate", params, socket) do
      {:noreply, assign(socket, form_data: params)}
    end

    def handle_event("submit", %{"test_form" => _params}, socket) do
      {:noreply, socket}
    end
  end

  describe "conditional field visibility" do
    test "company_name field is hidden initially when user_type is personal", %{conn: conn} do
      {:ok, _view, html} = live_isolated(conn, TestLive)

      # Check that the form renders
      assert html =~ "User Type"
      
      # Check that company_name field is not visible initially
      refute html =~ "Company Name"
      refute html =~ "company_name"
    end

    test "company_name field shows when user_type is set to company", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, TestLive)

      # Initially company_name should be hidden
      html = render(view)
      refute html =~ "Company Name"

      # Update the form data to select company
      view
      |> form(".form-builder-form", %{"user_type" => "company"})
      |> render_change()

      # Now company_name field should be visible
      html = render(view)
      assert html =~ "Company Name"
      assert html =~ "company_name"
    end

    test "company_name field hides again when user_type is set back to personal", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, TestLive)

      # First, select company to show the field
      view
      |> form(".form-builder-form", %{"user_type" => "company"})
      |> render_change()

      # Verify company_name is visible
      html = render(view)
      assert html =~ "Company Name"

      # Now select personal again
      view
      |> form(".form-builder-form", %{"user_type" => "personal"})
      |> render_change()

      # Company name field should be hidden again
      html = render(view)
      refute html =~ "Company Name"
      refute html =~ "company_name"
    end

    test "form updates correctly when changing radio selection", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, TestLive)

      # Change to company
      view
      |> form(".form-builder-form", %{"user_type" => "company"})
      |> render_change()

      html = render(view)
      assert html =~ "Company Name"

      # Fill in company name
      view
      |> form(".form-builder-form", %{"user_type" => "company", "company_name" => "Acme Corp"})
      |> render_change()

      # Change back to personal
      view
      |> form(".form-builder-form", %{"user_type" => "personal"})
      |> render_change()

      html = render(view)
      refute html =~ "Company Name"
    end
  end
end
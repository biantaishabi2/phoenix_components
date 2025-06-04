defmodule ShopUxPhoenixWeb.Components.SearchableSelectTest do
  use ShopUxPhoenixWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import ShopUxPhoenixWeb.Components.SearchableSelect

  describe "searchable_select/1" do
    test "renders basic searchable select with options" do
      assigns = %{
        id: "test-select",
        name: "category",
        options: [
          %{value: "tech", label: "Technology"},
          %{value: "design", label: "Design"}
        ],
        value: nil,
        placeholder: "Select category"
      }

      html = render_component(&searchable_select/1, assigns)

      assert html =~ "test-select"
      assert html =~ "category"
      assert html =~ "Select category"
      assert html =~ "searchable-select-container"
    end

    test "renders with selected value" do
      assigns = %{
        id: "test-select",
        name: "category",
        options: [
          %{value: "tech", label: "Technology"},
          %{value: "design", label: "Design"}
        ],
        value: "tech",
        placeholder: "Select category"
      }

      html = render_component(&searchable_select/1, assigns)

      assert html =~ "value=\"tech\""
      assert html =~ "Technology"
    end

    test "renders multiple selection mode" do
      assigns = %{
        id: "test-select",
        name: "categories",
        options: [
          %{value: "tech", label: "Technology"},
          %{value: "design", label: "Design"}
        ],
        value: ["tech", "design"],
        multiple: true,
        placeholder: "Select categories"
      }

      html = render_component(&searchable_select/1, assigns)

      assert html =~ "multiple"
      assert html =~ "categories[]"
      assert html =~ "Technology"
      assert html =~ "Design"
    end

    test "renders with grouped options" do
      assigns = %{
        id: "test-select",
        name: "department",
        options: [
          %{
            label: "Engineering",
            options: [
              %{value: "dev", label: "Development"},
              %{value: "qa", label: "Quality Assurance"}
            ]
          },
          %{
            label: "Marketing",
            options: [
              %{value: "seo", label: "SEO"},
              %{value: "content", label: "Content"}
            ]
          }
        ],
        value: nil,
        placeholder: "Select department"
      }

      html = render_component(&searchable_select/1, assigns)

      assert html =~ "optgroup"
      assert html =~ "Engineering"
      assert html =~ "Marketing"
      assert html =~ "Development"
      assert html =~ "SEO"
    end

    test "renders with custom option template" do
      assigns = %{
        id: "test-select",
        name: "user",
        options: [
          %{value: "1", label: "John Doe", email: "john@example.com", avatar: "/avatar1.jpg"},
          %{value: "2", label: "Jane Smith", email: "jane@example.com", avatar: "/avatar2.jpg"}
        ],
        value: nil,
        placeholder: "Select user"
      }

      html = render_component(&searchable_select/1, assigns)

      assert html =~ "John Doe"
      assert html =~ "john@example.com"
      assert html =~ "/avatar1.jpg"
    end

    test "renders disabled state" do
      assigns = %{
        id: "test-select",
        name: "category",
        options: [
          %{value: "tech", label: "Technology"}
        ],
        value: nil,
        disabled: true,
        placeholder: "Select category"
      }

      html = render_component(&searchable_select/1, assigns)

      assert html =~ "disabled"
      assert html =~ "cursor-not-allowed"
    end

    test "renders loading state" do
      assigns = %{
        id: "test-select",
        name: "category",
        options: [],
        value: nil,
        loading: true,
        placeholder: "Loading..."
      }

      html = render_component(&searchable_select/1, assigns)

      assert html =~ "loading"
      assert html =~ "animate-spin"
    end

    test "renders with allow_clear option" do
      assigns = %{
        id: "test-select",
        name: "category",
        options: [
          %{value: "tech", label: "Technology"}
        ],
        value: "tech",
        allow_clear: true,
        placeholder: "Select category"
      }

      html = render_component(&searchable_select/1, assigns)

      assert html =~ "clear-button"
      assert html =~ "×"
    end

    test "renders with max_tag_count for multiple selection" do
      assigns = %{
        id: "test-select",
        name: "skills",
        options: [
          %{value: "js", label: "JavaScript"},
          %{value: "css", label: "CSS"},
          %{value: "html", label: "HTML"},
          %{value: "react", label: "React"}
        ],
        value: ["js", "css", "html", "react"],
        multiple: true,
        max_tag_count: 2,
        placeholder: "Select skills"
      }

      html = render_component(&searchable_select/1, assigns)

      assert html =~ "+2"
    end

    test "renders with searchable disabled" do
      assigns = %{
        id: "test-select",
        name: "category",
        options: [
          %{value: "tech", label: "Technology"}
        ],
        value: nil,
        searchable: false,
        placeholder: "Select category"
      }

      html = render_component(&searchable_select/1, assigns)

      refute html =~ "search-input"
    end

    test "renders with remote search enabled" do
      assigns = %{
        id: "test-select",
        name: "product",
        options: [],
        value: nil,
        remote_search: true,
        placeholder: "Search products..."
      }

      html = render_component(&searchable_select/1, assigns)

      assert html =~ "remote-search"
      assert html =~ "phx-keyup"
    end

    test "renders with custom CSS classes" do
      assigns = %{
        id: "test-select",
        name: "category",
        options: [
          %{value: "tech", label: "Technology"}
        ],
        value: nil,
        class: "custom-select w-full",
        placeholder: "Select category"
      }

      html = render_component(&searchable_select/1, assigns)

      assert html =~ "custom-select"
      assert html =~ "w-full"
    end

    test "renders with errors" do
      assigns = %{
        id: "test-select",
        name: "category",
        options: [
          %{value: "tech", label: "Technology"}
        ],
        value: nil,
        errors: ["Category is required"],
        placeholder: "Select category"
      }

      html = render_component(&searchable_select/1, assigns)

      assert html =~ "Category is required"
      assert html =~ "border-red-500"
    end

    test "handles empty options list" do
      assigns = %{
        id: "test-select",
        name: "category",
        options: [],
        value: nil,
        placeholder: "No options available"
      }

      html = render_component(&searchable_select/1, assigns)

      assert html =~ "No options available"
      refute html =~ "<option"
    end

    test "renders with required attribute" do
      assigns = %{
        id: "test-select",
        name: "category",
        options: [
          %{value: "tech", label: "Technology"}
        ],
        value: nil,
        required: true,
        placeholder: "Select category"
      }

      html = render_component(&searchable_select/1, assigns)

      assert html =~ "required"
    end

    test "handles string value in options" do
      assigns = %{
        id: "test-select",
        name: "status",
        options: ["active", "inactive", "pending"],
        value: "active",
        placeholder: "Select status"
      }

      html = render_component(&searchable_select/1, assigns)

      assert html =~ "active"
      assert html =~ "inactive"
      assert html =~ "pending"
    end

    test "renders size variants" do
      for size <- ["sm", "md", "lg"] do
        assigns = %{
          id: "test-select-#{size}",
          name: "category",
          options: [%{value: "tech", label: "Technology"}],
          value: nil,
          size: size,
          placeholder: "Select category"
        }

        html = render_component(&searchable_select/1, assigns)
        assert html =~ "size-#{size}"
      end
    end
  end
end
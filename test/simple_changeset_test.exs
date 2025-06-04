defmodule SimpleChangesetTest do
  use ShopUxPhoenixWeb.ComponentCase
  import ShopUxPhoenixWeb.Components.FormBuilder
  
  defmodule SimpleSchema do
    use Ecto.Schema
    import Ecto.Changeset
    
    schema "simple" do
      field :name, :string
      field :email, :string
    end
    
    def changeset(schema, attrs) do
      schema
      |> cast(attrs, [:name, :email])
      |> validate_required([:name, :email])
    end
    
    def cast_fields, do: [:name, :email]
  end
  
  test "renders changeset form with debug" do
    # Enable debug
    # Application.put_env(:shop_ux_phoenix, :debug_form_builder, true)
    
    changeset = SimpleSchema.changeset(%SimpleSchema{}, %{})
    assigns = %{changeset: changeset}
    
    html = rendered_to_string(~H"""
      <.form_builder id="test-form" changeset={@changeset} />
    """)
    
    # Basic assertions
    assert html =~ "test-form"
    assert html =~ "form-builder"
  end
end
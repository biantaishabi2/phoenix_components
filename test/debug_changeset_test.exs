defmodule DebugChangesetTest do
  use ExUnit.Case
  
  defmodule TestSchema do
    use Ecto.Schema
    import Ecto.Changeset
    
    schema "test" do
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
  
  test "inspect changeset structure" do
    changeset = TestSchema.changeset(%TestSchema{}, %{})
    
    IO.puts "\n=== Changeset Structure ==="
    IO.inspect changeset, label: "Full changeset"
    IO.inspect changeset.data.__struct__, label: "Schema module"
    IO.inspect changeset.types, label: "Types"
    IO.inspect changeset.data.__struct__.__schema__(:fields), label: "Schema fields"
    
    # Test our get_cast_fields logic
    has_cast_fields = function_exported?(changeset.data.__struct__, :cast_fields, 0)
    IO.inspect has_cast_fields, label: "Has cast_fields function"
    
    if has_cast_fields do
      cast_fields = apply(changeset.data.__struct__, :cast_fields, [])
      IO.inspect cast_fields, label: "Cast fields from function"
    end
  end
end
defmodule DebugValidationsTest do
  use ExUnit.Case
  
  defmodule TestSchema do
    use Ecto.Schema
    import Ecto.Changeset
    
    schema "test" do
      field :name, :string
      field :role, :string
      field :age, :integer
    end
    
    def changeset(schema, attrs) do
      schema
      |> cast(attrs, [:name, :role, :age])
      |> validate_required([:name])
      |> validate_length(:name, min: 2, max: 10)
      |> validate_number(:age, greater_than_or_equal_to: 18)
      |> validate_inclusion(:role, ["admin", "user", "guest"])
    end
  end
  
  test "inspect validations structure" do
    changeset = TestSchema.changeset(%TestSchema{}, %{})
    
    IO.puts "\n=== Changeset Validations Structure ==="
    IO.inspect changeset.validations, label: "Validations"
    IO.inspect changeset.required, label: "Required fields"
    
    # Check specific validations
    IO.puts "\n=== Checking individual validations ==="
    Enum.each(changeset.validations, fn validation ->
      IO.inspect validation, label: "Validation"
    end)
  end
end
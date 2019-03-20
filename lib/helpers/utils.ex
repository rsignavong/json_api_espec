defmodule JsonApiEspec.Helpers.Utils do
  def atom_to_kebab_string(atom) do
    atom
    |> Atom.to_string()
    |> Recase.to_kebab()
  end

  def kebab_string_to_atom(kebab) do
    kebab
    |> Recase.to_snake()
    |> String.to_atom()
  end

  def struct_to_object(%_{} = struct) do
    struct
    |> Map.from_struct()
    |> Enum.reduce(%{}, fn {key, value}, acc_map ->
      string_key = atom_to_kebab_string(key)

      acc_map
      |> Map.put(string_key, value)
    end)
  end
end

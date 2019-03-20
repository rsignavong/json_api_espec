defmodule JsonApiEspec.Expectations.ResourceObject do
  defstruct expected_attributes: [], expected_type: nil, expected_meta: nil, resource: nil

  import JsonApiEspec.Helpers.Utils, only: [atom_to_kebab_string: 1, struct_to_object: 1]

  def resource_object(%_{} = resource) do
    map_resource = struct_to_object(resource)

    %__MODULE__{resource: map_resource}
  end

  def with_attributes(%__MODULE__{} = resource_object, expected_attributes)
      when is_list(expected_attributes) do
    expected_attributes =
      expected_attributes
      |> Enum.map(&atom_to_kebab_string/1)

    resource_object
    |> Map.put(:expected_attributes, expected_attributes)
  end

  def with_meta(%__MODULE__{} = resource_object, meta) when is_map(meta) do
    resource_object
    |> Map.put(:expected_meta, meta)
  end

  def with_type(%__MODULE__{} = resource_object, expected_type) when is_binary(expected_type) do
    resource_object
    |> Map.put(:expected_type, expected_type)
  end

  def map_attribute(%__MODULE__{} = resource_object, {key, value}) when is_atom(key) do
    string_key = atom_to_kebab_string(key)

    resource =
      resource_object.resource
      |> Map.put(string_key, value)

    resource_object
    |> Map.put(:resource, resource)
  end
end

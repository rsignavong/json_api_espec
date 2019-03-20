defmodule JsonApiEspec do
  alias JsonApiEspec.Expectations.{ResourceObject}
  alias JsonApiEspec.Assertions

  @moduledoc """
  Documentation for JsonApiEspec.
  """

  @doc """
  Have Resource Object.

  ## Examples

      iex> JsonApiEspec.hello()
      :world

  """
  def have_resource_object(%ResourceObject{} = resource_object) do
    {Assertions.ResourceObject, resource_object}
  end
end

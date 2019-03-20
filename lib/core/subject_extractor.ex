defmodule JsonApiEspec.Core.SubjectExtractor do
  alias JsonApiEspec.Core.Subject

  def get(origin_subject, type) when is_map(origin_subject) and is_atom(type) do
    case type do
      :resource_object ->
        origin_subject["data"] |> Map.take(["type", "id", "attributes", "meta"])
    end
  end

  def match_each(%Subject{data_ids: data_ids} = subject, key, fun)
      when is_atom(key) and is_function(fun, 1) do
    data_ids
    |> match_each(subject, key, fun)
  end

  defp match_each([], %Subject{} = subject, key, fun) when is_atom(key) and is_function(fun) do
    {true, subject}
  end

  defp match_each([id | ids], %Subject{} = subject, key, fun)
       when is_atom(key) and is_function(fun) do
    id
    |> find_id(subject, key)
    |> fun.()
    |> if do
      match_each(ids, subject, key, fun)
    else
      {false, {subject, key}}
    end
  end

  def find_first(%Subject{data_ids: data_ids} = subject, key) when is_atom(key) do
    data_ids
    |> List.first()
    |> case do
      nil ->
        :not_found

      id ->
        find_id(subject, key, id)
    end
    |> case do
      nil ->
        :not_found

      find ->
        find
    end
  end

  defp find_id(%Subject{} = subject, key, id) when is_atom(key) and is_binary(id) do
    subject
    |> Map.from_struct()
    |> get_in([key, id])
  end
end

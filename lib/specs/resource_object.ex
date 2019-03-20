defmodule JsonApiEspec.Specs.ResourceObject do
  alias JsonApiEspec.Core.{AssertionStep, Subject, SubjectExtractor}
  alias JsonApiEspec.Expectations.ResourceObject, as: ExpectedResourceObject

  import JsonApiEspec.Helpers.Utils, only: [kebab_string_to_atom: 1]

  def assert_data_meta(
        %AssertionStep{} = assertion_step,
        %Subject{data_ids: data_ids, data_meta: data_meta} = subject,
        %ExpectedResourceObject{expected_meta: expected_meta},
        optional \\ false
      )
      when is_boolean(optional) do
    case AssertionStep.remove_steps_to(assertion_step, [:data]) do
      :no_step_found ->
        assertion_step
        |> AssertionStep.step({:data, "data"})

      assertion_step ->
        assertion_step
    end
    |> AssertionStep.step({:meta, "meta"})
    |> (fn assertion_step ->
          subject
          |> SubjectExtractor.find_first(:data_meta)
          |> case do
            :not_found ->
              :parse_error

            actual_meta ->
              {expected_meta == actual_meta, actual_meta}
          end
          |> case do
            {true, _} ->
              {:ok, assertion_step}

            {false, actual_meta} ->
              {:error,
               AssertionStep.error(
                 assertion_step,
                 "have #{inspect(expected_meta)}",
                 inspect(actual_meta, pretty: true),
                 inspect(expected_meta, pretty: true)
               )}

            :parse_error ->
              if optional do
                {:ok, assertion_step}
              else
                {:error,
                 AssertionStep.parse_error(
                   assertion_step,
                   "have data object with id",
                   "no id",
                   "data with id"
                 )}
              end
          end
        end).()
  end

  def assert_data_type(
        %AssertionStep{} = assertion_step,
        %Subject{data_ids: data_ids, data_types: data_types} = subject,
        %ExpectedResourceObject{expected_type: expected_type},
        optional \\ false
      )
      when is_boolean(optional) do
    case AssertionStep.remove_steps_to(assertion_step, [:data]) do
      :no_step_found ->
        assertion_step
        |> AssertionStep.step({:data, "data"})

      assertion_step ->
        assertion_step
    end
    |> AssertionStep.step({:type, "type"})
    |> (fn assertion_step ->
          subject
          |> SubjectExtractor.find_first(:data_types)
          |> case do
            :not_found ->
              :parse_error

            actual_type ->
              {expected_type == actual_type, actual_type}
          end
          |> case do
            {true, _} ->
              {:ok, assertion_step}

            {false, actual_type} ->
              {:error,
               AssertionStep.error(
                 assertion_step,
                 "be #{expected_type}",
                 actual_type,
                 expected_type
               )}

            :parse_error ->
              if optional do
                {:ok, assertion_step}
              else
                {:error,
                 AssertionStep.parse_error(
                   assertion_step,
                   "have data object with id",
                   "no id",
                   "data with id"
                 )}
              end
          end
        end).()
  end

  def assert_data_id(
        %AssertionStep{} = assertion_step,
        %Subject{data_ids: data_ids} = subject,
        %ExpectedResourceObject{resource: %{"id" => expected_id}},
        optional \\ false
      )
      when is_boolean(optional) do
    case AssertionStep.remove_steps_to(assertion_step, [:data]) do
      :not_step_found ->
        assertion_step
        |> AssertionStep.step({:data, "data"})

      assertion_step ->
        assertion_step
    end
    |> AssertionStep.step({:id, "id"})
    |> (fn assertion_step ->
          data_ids
          |> List.first()
          |> case do
            nil ->
              :parse_error

            actual_id ->
              {expected_id == actual_id, actual_id}
          end
          |> case do
            {true, _} ->
              {:ok, assertion_step}

            {false, actual_id} ->
              {:error,
               AssertionStep.error(
                 assertion_step,
                 "be #{expected_id}",
                 actual_id,
                 expected_id
               )}

            :parse_error ->
              if optional do
                {:ok, assertion_step}
              else
                {:error,
                 AssertionStep.parse_error(
                   assertion_step,
                   "have data object with id",
                   "no id",
                   "data with id"
                 )}
              end
          end
        end).()
  end

  def assert_data_attributes_has_same_keys(
        %AssertionStep{} = assertion_step,
        %Subject{data_ids: data_ids, data_attributes: data_attributes} = subject,
        %ExpectedResourceObject{expected_attributes: expected_attributes},
        optional \\ false
      )
      when is_boolean(optional) do
    case AssertionStep.remove_steps_to(assertion_step, [:data]) do
      :not_step_found ->
        assertion_step
        |> AssertionStep.step({:data, "data"})

      assertion_step ->
        assertion_step
    end
    |> AssertionStep.step({:attributes, "attributes"})
    |> (fn assertion_step ->
          subject
          |> SubjectExtractor.find_first(:data_attributes)
          |> case do
            :not_found ->
              :parse_error

            actual_attributes ->
              actual_attributes
              |> Map.keys()
              |> (&{Enum.empty?(&1 -- expected_attributes) &&
                     Enum.empty?(expected_attributes -- &1), &1}).()
          end
          |> case do
            {true, _} ->
              {:ok, assertion_step}

            {false, actual_attributes_keys} ->
              {:error,
               AssertionStep.error(
                 assertion_step,
                 "have #{inspect(expected_attributes, pretty: true)} attributes",
                 actual_attributes_keys,
                 expected_attributes
               )}

            :parse_error ->
              if optional do
                {:ok, assertion_step}
              else
                {:error,
                 AssertionStep.parse_error(
                   assertion_step,
                   "have data object with id",
                   "no id",
                   "data with id"
                 )}
              end
          end
        end).()
  end

  def assert_data_attributes_values(
        %AssertionStep{} = assertion_step,
        %Subject{data_ids: data_ids, data_attributes: data_attributes} = subject,
        %ExpectedResourceObject{
          expected_attributes: expected_attributes,
          resource: resource
        },
        optional \\ false
      )
      when is_boolean(optional) do
    case AssertionStep.remove_steps_to(assertion_step, [:data]) do
      :not_step_found ->
        assertion_step
        |> AssertionStep.step({:data, "data"})

      assertion_step ->
        assertion_step
    end
    |> AssertionStep.step({:attributes, "attributes"})
    |> (fn assertion_step ->
          subject
          |> SubjectExtractor.find_first(:data_attributes)
          |> case do
            :not_found ->
              :parse_error

            actual_attributes ->
              match_attribute_values(expected_attributes, resource, actual_attributes)
          end
          |> case do
            {true, _} ->
              {:ok, assertion_step}

            {false, attribute, expected_attribute, actual_attribute} ->
              assertion_step
              |> AssertionStep.step({attribute |> kebab_string_to_atom(), attribute})
              |> (&{:error,
                   AssertionStep.error(
                     &1,
                     "have #{inspect(expected_attribute, pretty: true)}",
                     actual_attribute,
                     expected_attribute
                   )}).()

            :parse_error ->
              if optional do
                {:ok, assertion_step}
              else
                {:error,
                 AssertionStep.parse_error(
                   assertion_step,
                   "have data object with id",
                   "no id",
                   "data with id"
                 )}
              end
          end
        end).()
  end

  defp match_attribute_values([], expected, _actual) do
    {true, expected}
  end

  defp match_attribute_values([attr | attrs], expected, actual) do
    if expected[attr] == actual[attr] do
      match_attribute_values(attrs, expected, actual)
    else
      {false, attr, expected[attr], actual[attr]}
    end
  end

  # def assert_relationships_is_map(%AssertionStep{} = assertion_step) do
  #   case AssertionStep.find(assertion_step, :data) do
  #     :not_found ->
  #       {:impl_error, assertion_step}

  #     {:data, resource_object} ->
  #       case AssertionStep.remove_steps_to(assertion_step, [:data]) do
  #         :no_step_found ->
  #           {:impl_error, assertion_step}

  #         assertion_step ->
  #           key = :relationships
  #           field = "relationships"

  #           assertion_step = AssertionStep.step(assertion_step, {key, field})

  #           if Map.has_key?(resource_object, "relationships") do
  #             relationships = resource_object["relationships"]

  #             if is_map(relationships) do
  #               {:ok, AssertionStep.data(assertion_step, {key, relationships})}
  #             else
  #               {:error,
  #                AssertionStep.error(
  #                  assertion_step,
  #                  "have `relationships` as map property",
  #                  "relationships is not a map",
  #                  %{}
  #                )}
  #             end
  #           else
  #             {:error,
  #              AssertionStep.error(
  #                assertion_step,
  #                "have `relationships` property",
  #                "no relationships found",
  #                field
  #              )}
  #           end
  #       end
  #   end
  # end

  # def assert_same_resource_ids(subject_data, resources) do
  #   subject_ids =
  #     subject_data
  #     |> Enum.map(&Map.get(&1, "id"))

  #   expected_ids =
  #     resources
  #     |> Enum.map(&Map.from_struct/1)
  #     |> Enum.map(&Map.get(&1, :id))

  #   if Enum.empty?(subject_ids -- expected_ids) && Enum.empty?(expected_ids -- subject_ids) do
  #     :ok
  #   else
  #     {:error, :not_same_resource_ids, subject_ids, expected_ids}
  #   end
  # end

  # def assert_resources(_subject_data, []) do
  #   :ok
  # end

  # def assert_resources(subject_data, [%ResourceMatcher{} = resource | resources]) do
  #   with {:ok, subject_resource} <- find_resource(subject_data, resource),
  #        :ok <- assert_type(subject_resource, resource),
  #        :ok <- assert_id(subject_resource, resource),
  #        {:ok, subject_attributes} <- assert_attributes(subject_resource),
  #        :ok <- assert_exact_attributes(subject_attributes, resource),
  #        :ok <- assert_expected_attributes(subject_attributes, resource) do
  #     assert_resources(subject_data, resources)
  #   else
  #     {:error, code, actual} ->
  #       {:error, code, resource, actual}

  #     {:error, code, actual, expected} ->
  #       {:error, code, resource, actual, expected}

  #     {:error, code, attribute, actual, expected} ->
  #       {:error, code, resource, attribute, actual, expected}
  #   end
  # end

  # def find_resource(subject_data, %ResourceMatcher{resource: %{"id" => expected_id}}) do
  #   subject_data
  #   |> Enum.find(fn data -> match?(%{"id" => ^expected_id}, data) end)
  #   |> case do
  #     nil ->
  #       actual_ids =
  #         subject_data
  #         |> Enum.map(fn data -> data["id"] end)

  #       {:error, :not_found, actual_ids, expected_id}

  #     subject_resource ->
  #       {:ok, subject_resource}
  #   end
  # end
  # def assert_count(subject_data, expected_count) do
  #   subject_count =
  #     subject_data
  #     |> Enum.count()

  #   if subject_count == expected_count do
  #     :ok
  #   else
  #     {:error, :bad_count, subject_count, expected_count}
  #   end
  # end

  # def assert_sorted_ids(subject_data, resources) do
  #   subject_ids =
  #     subject_data
  #     |> Enum.map(&Map.get(&1, "id"))

  #   expected_ids =
  #     resources
  #     |> Enum.map(&Map.from_struct/1)
  #     |> Enum.map(&Map.get(&1, :id))

  #   if subject_ids == expected_ids do
  #     :ok
  #   else
  #     {:error, :not_sorted, subject_ids, expected_ids}
  #   end
  # end
end

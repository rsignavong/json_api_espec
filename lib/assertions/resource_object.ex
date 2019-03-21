defmodule JsonApiEspec.Assertions.ResourceObject do
  use ESpec.Assertions.Interface
  alias JsonApiEspec.Core.{AssertionStep, SubjectParser, SubjectExtractor}
  alias JsonApiEspec.Expectations.ResourceObject, as: ExpectedResourceObject
  alias JsonApiEspec.Specs.ResourceObject

  defp match(subject, %ExpectedResourceObject{} = expected) do
    steps = AssertionStep.init()

    with {:ok, sub} <- SubjectParser.parse(subject),
         {:ok, steps} <- ResourceObject.assert_data_meta(steps, sub, expected, true),
         {:ok, steps} <- ResourceObject.assert_data_type(steps, sub, expected),
         {:ok, steps} <- ResourceObject.assert_data_id(steps, sub, expected),
         {:ok, steps} <-
           ResourceObject.assert_data_attributes_has_same_keys(steps, sub, expected),
         {:ok, _steps} <- ResourceObject.assert_data_attributes_values(steps, sub, expected) do
      {true, SubjectExtractor.get(subject, :resource_object)}
    else
      {:parse_error, code} ->
        {false, {:parse, code}}

      {:impl_error, steps} ->
        {false, {:impl, steps}}

      {:error, steps} ->
        {false, AssertionStep.failure(steps)}
    end
  end

  defp success_message(_subject, _data, result, _positive) do
    "#{inspect(result)}"
  end

  defp error_message(subject, _data, {:parse, code}, _positive) do
    "Parser error #{code}, check the subject.\n#{inspect(subject, pretty: true)}"
  end

  defp error_message(_subject, _data, {:impl, steps}, _positive) do
    "Implementation error, check the Assertion pipeline.\n#{inspect(steps, pretty: true)}"
  end

  defp error_message(_subject, _data, {fields, expected_msg, actual, expected}, positive) do
    to = if positive, do: "to", else: "not to"
    does = if positive, do: "doesn't", else: "does"

    msg = "Expected #{fields} #{to} #{expected_msg}, but it #{does}"

    if positive do
      {msg, %{diff_fn: fn -> ESpec.Diff.diff(actual, expected) end}}
    else
      msg
    end
  end
end

defmodule JsonApiEspec.Core.AssertionStep do
  defstruct steps: [], expected_msg: "", actual: nil, expected: nil

  def init() do
    %__MODULE__{}
  end

  def step(%__MODULE__{steps: steps} = assertion_step, {step, field} = step_field)
      when is_atom(step) and is_binary(field) do
    assertion_step
    |> Map.put(:steps, [step_field | steps])
  end

  def remove_steps_to(%__MODULE__{steps: steps} = assertion_step, parent_steps)
      when is_list(parent_steps) do
    case find_step(steps, parent_steps) do
      :no_step_found ->
        :no_step_found

      steps ->
        assertion_step
        |> Map.put(:steps, steps)
    end
  end

  def error(%__MODULE__{} = assertion_step, expected_msg, actual, expected)
      when is_binary(expected_msg) do
    assertion_step
    |> Map.put(:expected_msg, expected_msg)
    |> Map.put(:actual, actual)
    |> Map.put(:expected, expected)
  end

  def parse_error(%__MODULE__{steps: steps} = assertion_step, expected_msg, actual, expected)
      when is_binary(expected_msg) do
    assertion_step
    |> Map.put(:steps, [{:response, "response"}])
    |> Map.put(:expected_msg, expected_msg)
    |> Map.put(:actual, actual)
    |> Map.put(:expected, expected)
  end

  def failure(%__MODULE__{
        steps: steps,
        expected_msg: expected_msg,
        actual: actual,
        expected: expected
      }) do
    steps
    |> Enum.map(fn {_step, field} -> field end)
    |> Enum.reverse()
    |> Enum.join(" > ")
    |> (&{
          &1,
          expected_msg,
          actual,
          expected
        }).()
  end

  defp find_step(_steps, []) do
    :no_step_found
  end

  defp find_step(steps, [to_find | to_finds]) do
    case find_in_steps(steps, to_find) do
      :not_found ->
        find_step(steps, to_finds)

      steps ->
        steps
    end
  end

  defp find_in_steps([], _to_find) do
    :not_found
  end

  defp find_in_steps([{step, _value} | next_steps] = steps, to_find) do
    if step == to_find do
      steps
    else
      find_in_steps(next_steps, to_find)
    end
  end
end

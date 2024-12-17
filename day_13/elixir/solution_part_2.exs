defmodule Solution do
  def solve(goal, a, b) do
    goal
    |> to_matrix(a, b)
    |> solve_by_cramers_rule()
    |> Enum.map(&Integer.parse(Float.to_string(&1)))
    |> then(fn
      [{a_factor, ".0"}, {b_factor, ".0"}] -> a_factor * 3 + b_factor
      _ -> 0
    end)
  end

  defp solve_by_cramers_rule({{a, b, e}, {c, d, f}} = matrix) do
    det = determinant(matrix)

    a_factor = (e * d - b * f) / det
    b_factor = (a * f - e * c) / det

    [a_factor, b_factor]
  end

  defp determinant({{a, b, _e}, {c, d, _f}}), do: a * d - b * c

  defp to_matrix({gx, gy}, {ax, ay}, {bx, by}) do
    {
      {ax, bx, gx},
      {ay, by, gy}
    }
  end

  def parse_button_text(line) do
    line
    |> String.split(~r/\W/, trim: true)
    |> then(fn
      ["Button", _a_or_b, "X", x, "Y", y] -> {String.to_integer(x), String.to_integer(y)}
    end)
  end

  def parse_goal(line) do
    oh_wait = 10_000_000_000_000

    line
    |> String.split(~r/\W/, trim: true)
    |> then(fn
      ["Prize", "X", x, "Y", y] ->
        {String.to_integer(x) + oh_wait, String.to_integer(y) + oh_wait}
    end)
  end
end

"../input.txt"
|> File.read!()
|> String.split("\n\n", trim: true)
|> Enum.reduce(_total_tokens = 0, fn scenario, token_cost ->
  scenario
  |> String.split("\n", trim: true)
  |> then(fn [button_a, button_b, prize] ->
    a = Solution.parse_button_text(button_a)
    b = Solution.parse_button_text(button_b)
    goal = Solution.parse_goal(prize)

    token_cost + Solution.solve(goal, a, b)
  end)
end)
|> IO.inspect(charlists: :as_lists, limit: :infinity)

basically_infinity = 1_000_000_000_000

defmodule Solution do
  @basically_infinity basically_infinity

  def costs(
        goal,
        a,
        b,
        cost \\ 0,
        lowest_cost \\ @basically_infinity,
        ac \\ 0,
        bc \\ 0,
        used \\ %{}
      )

  def costs({goalx, goaly}, _a, _b, _cost, lowest_cost, _ac, _bc, used)
      when goalx < 0 or goaly < 0,
      do: {used, lowest_cost}

  def costs({0, 0}, _a, _b, cost, lowest_cost, _ac, _bc, used),
    do: if(cost < lowest_cost, do: {used, cost}, else: {used, lowest_cost})

  def costs(_goal, _a, _b, cost, lowest_cost, _ac, _bc, used) when cost >= lowest_cost,
    do: {used, lowest_cost}

  def costs(goal, a, b, cost, lowest_cost, ac, bc, used) do
    [goal: a_goal, cost: a_cost] = pick(goal, cost, 3, a)
    [goal: b_goal, cost: b_cost] = pick(goal, cost, 1, b)

    if Map.get(used, {ac, bc}, false) do
      # IO.inspect("CA$H HIT")
      {used, lowest_cost}
    else
      used = Map.put(used, {ac, bc}, true)

      {used, b_lowest} =
        costs(b_goal, a, b, b_cost, lowest_cost, ac, bc + 1, used)

      if b_lowest < lowest_cost do
        {used, b_lowest}
      else
        costs(a_goal, a, b, a_cost, b_lowest, ac + 1, bc, used)
      end
    end
  end

  defp pick({goalx, goaly}, cost, cost_inc, {x, y}) do
    [goal: {goalx - x, goaly - y}, cost: cost + cost_inc]
  end

  def parse_button_text(line) do
    line
    |> String.split(~r/\W/, trim: true)
    |> then(fn
      ["Button", _a_or_b, "X", x, "Y", y] -> {String.to_integer(x), String.to_integer(y)}
    end)
  end

  def parse_goal(line) do
    line
    |> String.split(~r/\W/, trim: true)
    |> then(fn
      ["Prize", "X", x, "Y", y] -> {String.to_integer(x), String.to_integer(y)}
    end)
  end
end

"""
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
"""

"../input.txt"
|> File.read!()
|> String.split("\n\n", trim: true)
|> Enum.map(fn scenario ->
  scenario
  |> String.split("\n", trim: true)
  |> then(fn [button_a, button_b, prize] ->
    a = Solution.parse_button_text(button_a)
    b = Solution.parse_button_text(button_b)
    goal = Solution.parse_goal(prize)

    {_used, cost} = Solution.costs(goal, a, b)
    cost
  end)
end)
|> Enum.filter(fn
  ^basically_infinity -> false
  _cost -> true
end)
|> Enum.sum()
|> IO.inspect(charlists: :as_lists, limit: :infinity)

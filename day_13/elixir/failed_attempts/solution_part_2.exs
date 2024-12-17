basically_infinity = 1_000_000_000_000_000_000_000

defmodule Solution do
  @basically_infinity basically_infinity

  def costs(
        goal,
        a,
        b,
        initial_goal,
        cost \\ 0,
        lowest_cost \\ @basically_infinity,
        ac \\ 0,
        bc \\ 0,
        used \\ %{}
      )

  def costs({goalx, goaly}, _a, _b, _initial_goal, _cost, lowest_cost, _ac, _bc, used)
      when goalx < 0 or goaly < 0,
      do: {used, lowest_cost}

  def costs({0, 0}, _a, _b, _initial_goal, cost, lowest_cost, _ac, _bc, used),
    do: if(cost < lowest_cost, do: {used, cost}, else: {used, lowest_cost})

  def costs(_goal, _a, _b, _initial_goal, cost, lowest_cost, _ac, _bc, used)
      when cost >= lowest_cost,
      do: {used, lowest_cost}

  def costs(goal, a, b, initial_goal, cost, lowest_cost, ac, bc, used) do
    [goal: a_goal, cost: a_cost] = pick(goal, cost, 3, a)
    [goal: b_goal, cost: b_cost] = pick(goal, cost, 1, b)

    dist = distance({0, 0}, initial_goal, goal)
    # IO.inspect(dist: dist, initial_goal: initial_goal, goal: goal)

    # if dist < 1 do
    #   IO.inspect(goal: goal, dist: dist)
    # end

    if ac > 10_000_000 or bc > 10_000_000 do
      {:give_up, used, lowest_cost}
    else
      if dist < 0.000000000000001 and initial_goal != goal do
        IO.inspect([goal: goal, ac: ac, bc: bc, cost: cost],
          label: "on line"
        )

        {:on_line, ac, bc}
      else
        if Map.get(used, {ac, bc}, false) or dist > 30 do
          # if dist_a > 50, do: IO.inspect(dist_a, label: "dist")

          # IO.inspect("CA$H HIT")
          {used, lowest_cost}
        else
          used = Map.put(used, {ac, bc}, true)

          case costs(b_goal, a, b, initial_goal, b_cost, lowest_cost, ac, bc + 1, used) do
            {:give_up, used, cost} ->
              {used, cost}

            {:on_line, _ac, _bc} = on_line ->
              on_line

            {used, b_lowest} ->
              if b_lowest < lowest_cost do
                {used, b_lowest}
              else
                costs(a_goal, a, b, initial_goal, a_cost, b_lowest, ac + 1, bc, used)
              end
          end
        end
      end
    end
  end

  defp pick({goalx, goaly}, cost, cost_inc, {x, y}) do
    [goal: {goalx - x, goaly - y}, cost: cost + cost_inc]
  end

  defp distance({p1x, p1y}, {p2x, p2y}, {x, y}) do
    abs((p2y - p1y) * x - (p2x - p1x) * y + p2x * p1y - p2y * p1x) /
      :math.sqrt(:math.pow(p2y - p1y, 2) + :math.pow(p2x - p1x, 2))
  end

  def parse_button_text(line) do
    line
    |> String.split(~r/\W/, trim: true)
    |> then(fn
      ["Button", _a_or_b, "X", x, "Y", y] -> {String.to_integer(x), String.to_integer(y)}
    end)
  end

  def parse_goal(line) do
    oh_actually = 10_000_000_000_000
    # oh_actually = 0

    line
    |> String.split(~r/\W/, trim: true)
    |> then(fn
      ["Prize", "X", x, "Y", y] ->
        {String.to_integer(x) + oh_actually, String.to_integer(y) + oh_actually}
    end)
  end

  def repeatedly(goal, a, b, a_factor, b_factor, cost \\ 0)

  def repeatedly({0, 0}, _a, _b, _a_factor, _b_factor, cost), do: cost

  def repeatedly({gx, gy}, {ax, ay} = a, {bx, by} = b, a_factor, b_factor, cost)
      when gx > 0 and gy > 0 do
    # IO.inspect({gx, gy})
    # TODO this is still slow
    gx = gx - ax * a_factor
    gy = gy - ay * a_factor

    gx = gx - bx * b_factor
    gy = gy - by * b_factor

    cost = cost + a_factor * 3
    cost = cost + b_factor

    repeatedly({gx, gy}, a, b, a_factor, b_factor, cost)
  end
end

"""
Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176
"""
|> String.split("\n\n", trim: true)
|> Enum.map(fn scenario ->
  scenario
  |> String.split("\n", trim: true)
  |> then(fn [button_a, button_b, prize] ->
    a = Solution.parse_button_text(button_a)
    b = Solution.parse_button_text(button_b)
    goal = Solution.parse_goal(prize)

    cost =
      case Solution.costs(goal, a, b, goal) do
        {:on_line, a_factor, b_factor} -> Solution.repeatedly(goal, a, b, a_factor, b_factor)
        {:give_up, _used, cost} -> cost
        {_used, cost} -> cost
      end

    IO.inspect(goal, label: "cost #{cost}")
    cost
  end)
end)
|> Enum.filter(fn
  ^basically_infinity -> false
  _cost -> true
end)
|> Enum.sum()
|> IO.inspect(charlists: :as_lists, limit: :infinity)

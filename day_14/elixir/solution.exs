width = 101
height = 103

defmodule Solution do
  @width width
  @height height

  def move([position: {px, py}, velocity: {vx, vy} = velocity] = _robot) do
    dx = px + vx
    dy = py + vy

    px =
      cond do
        dx < 0 -> @width - abs(dx)
        dx >= @width -> rem(dx, @width)
        true -> dx
      end

    py =
      cond do
        dy < 0 -> @height - abs(dy)
        dy >= @height -> rem(dy, @height)
        true -> dy
      end

    [position: {px, py}, velocity: velocity]
  end

  def quadrant_counts(robots) do
    q_width = div(@width, 2)
    q_height = div(@height, 2)

    Enum.group_by(robots, fn [position: {px, py}, velocity: _velocity] ->
      cond do
        px <= q_width - 1 and py <= q_height - 1 -> :q1
        px >= q_width + 1 and py <= q_height - 1 -> :q2
        px <= q_width - 1 and py >= q_height + 1 -> :q3
        px >= q_width + 1 and py >= q_height + 1 -> :q4
        true -> :middle
      end
    end)
  end
end

"../input.txt"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(fn line ->
  line
  |> String.split(~r/[^-0-9]/, trim: true)
  |> Enum.map(&String.to_integer/1)
  |> then(fn [px, py, vx, vy] ->
    [position: {px, py}, velocity: {vx, vy}]
  end)
end)
|> Enum.map(fn robot ->
  Enum.reduce(0..99, robot, fn _n, robot -> Solution.move(robot) end)
end)
|> Solution.quadrant_counts()
|> then(fn %{q1: q1, q2: q2, q3: q3, q4: q4} ->
  length(q1) * length(q2) * length(q3) * length(q4)
end)
|> IO.inspect()

width = 101
height = 103

defmodule Solution do
  @width width
  @height height

  @row 1..@width |> Enum.map(fn _ -> " " end) |> List.to_tuple()
  @grid 1..@height |> Enum.map(fn _ -> @row end) |> List.to_tuple()

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

    robots
    |> Enum.group_by(fn [position: {px, py}, velocity: _velocity] ->
      cond do
        px <= q_width - 1 and py <= q_height - 1 -> :q1
        px >= q_width + 1 and py <= q_height - 1 -> :q2
        px <= q_width - 1 and py >= q_height + 1 -> :q3
        px >= q_width + 1 and py >= q_height + 1 -> :q4
        true -> :middle
      end
    end)
  end

  def quadrant_symmetry(%{q1: q1, q2: q2, q3: q3, q4: q4}) do
    # idea here is that robots will appear in symmetric positions
    # across the vertical access.

    q2_mapping = Enum.into(q2, %{}, fn [position: p, velocity: _] -> {p, true} end)
    q4_mapping = Enum.into(q4, %{}, fn [position: p, velocity: _] -> {p, true} end)

    top_half =
      q1
      |> Enum.reduce(0, fn [position: {px, py}, velocity: _], symmetric_points ->
        target = {@width - 1 - px, py}

        case Map.get(q2_mapping, target) do
          nil -> symmetric_points
          true -> symmetric_points + 1
        end
      end)

    bottom_half =
      q3
      |> Enum.reduce(0, fn [position: {px, py}, velocity: _], symmetric_points ->
        target = {@width - 1 - px, py}

        case Map.get(q4_mapping, target) do
          nil -> symmetric_points
          true -> symmetric_points + 1
        end
      end)

    {Float.round(top_half / (length(q1) + length(q2)), 4) * 100,
     Float.round(bottom_half / (length(q3) + length(q4)), 4) * 100}
  end

  def quadrant_ratios(%{q1: q1, q2: q2, q3: q3, q4: q4}) do
    # idea here is that q1 : q2, and q3 : q3 should be a ratio 
    # that is close to 1 if there's a christmas tree.

    places = 10

    q1_to_q2 = abs(length(q1) / length(q2))
    q3_to_q4 = abs(length(q3) / length(q4))

    top_half = Float.round(abs(1 - q1_to_q2), places)
    bottom_half = Float.round(abs(1 - q3_to_q4), places)

    {top_half, bottom_half}
  end

  def output(picture, file, sec) do
    data =
      picture
      |> Tuple.to_list()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map_join("\n", & &1)

    IO.write(file, "\n\nSEC #{sec}\n\n")
    IO.write(file, data)

    picture
  end

  def grid(), do: @grid
end

File.open("../output.txt", [:write, :append], fn file ->
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
  |> then(fn robots ->
    1..16_646
    |> Enum.reduce({%{}, robots}, fn sec, {similar_ratios, robots} ->
      robots = Enum.map(robots, &Solution.move/1)

      picture =
        robots
        |> Enum.reduce(Solution.grid(), fn [position: {px, py}, velocity: _], picture ->
          row = put_elem(elem(picture, py), px, "x")
          put_elem(picture, py, row)
        end)

      key = :erlang.term_to_binary(picture)
      Solution.output(picture, file, sec)

      similar_ratios =
        Map.update(similar_ratios, key, [sec], fn
          [_, _] = existing ->
            existing

          sex ->
            IO.inspect(sec)
            [sec | sex]
        end)

      {similar_ratios, robots}
    end)
  end)
  |> then(&elem(&1, 0))
  |> Enum.reject(fn
    {_k, [_]} -> true
    _ -> false
  end)
end)

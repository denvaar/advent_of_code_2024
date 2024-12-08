defmodule Solution do
  def find_antinodes(positions, grid, acc \\ [])

  def find_antinodes([], _grid, acc), do: acc

  def find_antinodes([p1 | positions], grid, acc) do
    antinode_funcs =
      positions
      |> Enum.map(fn p2 ->
        [p1, p2]
        |> sort_points()
        |> then(fn points -> {points, &calc_funcs/1} end)
      end)

    find_antinodes(positions, grid, acc ++ antinode_funcs)
  end

  defp sort_points([{p1_r, p1_c} = p1, {p2_r, p2_c} = p2]) do
    cond do
      p1_r < p2_r -> [p1, p2]
      p1_r > p2_r -> [p2, p1]
      p1_r == p2_r -> if p1_c <= p2_c, do: [p1, p2], else: [p2, p1]
    end
  end

  defp calc_funcs([{p1_r, p1_c} = p1, {p2_r, p2_c} = p2]) do
    row_dist = abs(elem(p1, 0) - elem(p2, 0))
    col_dist = abs(elem(p1, 1) - elem(p2, 1))

    cond do
      p1_r < p2_r and p1_c > p2_c ->
        [
          fn {r, c} -> {r - row_dist, c + col_dist} end,
          fn {r, c} -> {r + row_dist, c - col_dist} end
        ]

      p1_r < p2_r and p1_c < p2_c ->
        [
          fn {r, c} -> {r - row_dist, c - col_dist} end,
          fn {r, c} -> {r + row_dist, c + col_dist} end
        ]
    end
  end

  def all_positions(p1, p2, p1_fn, p2_fn, grid, positions \\ [])

  def all_positions(p1, p2, p1_fn, p2_fn, grid, positions) do
    positions =
      [p1, p2]
      |> Enum.reduce(positions, fn p, positions ->
        if p in Map.keys(grid) do
          [p | positions]
        else
          positions
        end
      end)

    if Enum.any?([p1, p2], &(&1 in Map.keys(grid))) do
      all_positions(p1_fn.(p1), p2_fn.(p2), p1_fn, p2_fn, grid, positions)
    else
      positions
    end
  end
end

"../input.txt"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.with_index()
|> Enum.reduce(%{}, fn {line, row_idx}, grid ->
  line
  |> String.split("", trim: true)
  |> Enum.with_index()
  |> Enum.reduce(grid, fn {char, col_idx}, grid ->
    Map.put(grid, {row_idx, col_idx}, char)
  end)
end)
|> then(fn grid ->
  grouped = grid |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))

  grouped
  |> Enum.reduce(MapSet.new([]), fn
    {".", _positions}, antinode_positions ->
      antinode_positions

    {_freq, positions}, antinode_positions ->
      positions
      |> Solution.find_antinodes(grid)
      |> Enum.reduce(antinode_positions, fn
        {[p1, p2] = points, calc_func}, antinode_positions ->
          [p1_fn, p2_fn] = points |> calc_func.()

          Solution.all_positions(p1, p2, p1_fn, p2_fn, grid)
          |> MapSet.new()
          |> MapSet.union(antinode_positions)
      end)
  end)
end)
|> MapSet.size()
|> IO.inspect()

defmodule Solution do
  def find_antinodes(positions, grid, acc \\ [])

  def find_antinodes([], _grid, acc), do: acc

  def find_antinodes([p1 | positions], grid, acc) do
    antinodes =
      positions
      |> Enum.flat_map(fn p2 ->
        [p1, p2]
        |> sort_points()
        |> calc()
      end)

    find_antinodes(positions, grid, acc ++ antinodes)
  end

  defp sort_points([{p1_r, p1_c} = p1, {p2_r, p2_c} = p2]) do
    cond do
      p1_r < p2_r -> [p1, p2]
      p1_r > p2_r -> [p2, p1]
      p1_r == p2_r -> if p1_c <= p2_c, do: [p1, p2], else: [p2, p1]
    end
  end

  defp calc([{p1_r, p1_c} = p1, {p2_r, p2_c} = p2]) do
    row_dist = abs(elem(p1, 0) - elem(p2, 0))
    col_dist = abs(elem(p1, 1) - elem(p2, 1))

    cond do
      p1_r < p2_r and p1_c > p2_c ->
        [
          {p1_r - row_dist, p1_c + col_dist},
          {p2_r + row_dist, p2_c - col_dist}
        ]

      p1_r < p2_r and p1_c < p2_c ->
        [
          {p1_r - row_dist, p1_c - col_dist},
          {p2_r + row_dist, p2_c + col_dist}
        ]
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
    {".", _positions}, total ->
      total

    {_freq, positions}, total ->
      positions
      |> Solution.find_antinodes(grid)
      |> Enum.filter(fn antinode_pos ->
        antinode_pos in Map.keys(grid)
      end)
      |> Enum.reduce(total, fn antinode, total ->
        MapSet.put(total, antinode)
      end)
  end)
end)
|> MapSet.size()
|> IO.inspect()

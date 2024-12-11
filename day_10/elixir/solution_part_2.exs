defmodule Solution do
  def all_paths(grid, pos, paths \\ [])

  def all_paths(grid, pos, paths) do
    if Map.get(grid, pos) == 9 do
      [pos | paths]
      |> Enum.reverse()
      |> then(&[&1])
    else
      paths = [pos | paths]

      grid
      |> neighbors(pos)
      |> Enum.flat_map(fn n -> all_paths(grid, n, paths) end)
    end
  end

  defp neighbors(grid, {r, c} = pos) do
    top_position = {r - 1, c}
    bottom_position = {r + 1, c}
    left_position = {r, c - 1}
    right_position = {r, c + 1}

    current_value = Map.get(grid, pos)

    [top_position, bottom_position, left_position, right_position]
    |> Enum.filter(fn value ->
      Map.get(grid, value) == current_value + 1
    end)
  end

  def starting_points(grid) do
    grid
    |> Map.filter(fn {_k, v} -> v == 0 end)
    |> Enum.map(&elem(&1, 0))
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
    Map.put(grid, {row_idx, col_idx}, String.to_integer(char))
  end)
end)
|> then(fn grid ->
  grid
  |> Solution.starting_points()
  |> Enum.map(fn point ->
    grid
    |> Solution.all_paths(point)
    |> Enum.count()
  end)
end)
|> Enum.sum()
|> IO.inspect()

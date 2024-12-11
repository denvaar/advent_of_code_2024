defmodule Solution do
  def starting_points(grid) do
    grid
    |> Map.filter(fn {_k, v} -> v == 0 end)
    |> Enum.map(&elem(&1, 0))
  end

  def score_trail(_grid, position, 9), do: position

  def score_trail(grid, position, _value) do
    grid
    |> neighbors(position)
    |> Enum.reduce([], fn n, winners ->
      [score_trail(grid, n, Map.get(grid, n)) | winners]
    end)
    |> List.flatten()
  end

  defp neighbors(grid, {r, c} = position) do
    top_position = {r - 1, c}
    bottom_position = {r + 1, c}
    left_position = {r, c - 1}
    right_position = {r, c + 1}

    current_value = Map.get(grid, position)

    [top_position, bottom_position, left_position, right_position]
    |> Enum.filter(fn value ->
      Map.get(grid, value) == current_value + 1
    end)
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
    |> Solution.score_trail(point, Map.get(grid, point))
    |> Enum.uniq()
    |> Enum.count()
  end)
end)
|> Enum.sum()
|> IO.inspect()

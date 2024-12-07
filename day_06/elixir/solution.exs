defmodule Solution do
  def walk(grid, {r, c} = cell, :up = direction) do
    next_cell = {r - 1, c}

    case Map.get(grid, next_cell) do
      "#" -> grid |> Map.put(cell, "o") |> walk(cell, :right)
      nil -> grid
      _ -> grid |> Map.put(cell, "o") |> walk(next_cell, direction)
    end
  end

  def walk(grid, {r, c} = cell, :right = direction) do
    next_cell = {r, c + 1}

    case Map.get(grid, next_cell) do
      "#" -> grid |> Map.put(cell, "o") |> walk(cell, :down)
      nil -> grid
      _ -> grid |> Map.put(cell, "o") |> walk(next_cell, direction)
    end
  end

  def walk(grid, {r, c} = cell, :down = direction) do
    next_cell = {r + 1, c}

    case Map.get(grid, next_cell) do
      "#" -> grid |> Map.put(cell, "o") |> walk(cell, :left)
      nil -> grid
      _ -> grid |> Map.put(cell, "o") |> walk(next_cell, direction)
    end
  end

  def walk(grid, {r, c} = cell, :left = direction) do
    next_cell = {r, c - 1}

    case Map.get(grid, next_cell) do
      "#" -> grid |> Map.put(cell, "o") |> walk(cell, :up)
      nil -> grid
      _ -> grid |> Map.put(cell, "o") |> walk(next_cell, direction)
    end
  end
end

"""
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"""

"../input.txt"
|> File.read!()
|> String.split("\n", trim: true)
|> then(fn lines ->
  # 86,49 -> 85,48

  lines
  |> Enum.with_index()
  |> Enum.reduce(%{}, fn {line, row_idx}, grid ->
    line
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(grid, fn {cell, col_idx}, grid ->
      grid
      |> Map.put({row_idx, col_idx}, cell)
    end)
    |> Map.merge(grid)
  end)
end)
|> then(fn grid ->
  grid |> Map.get({48, 85}) |> IO.inspect()
  Solution.walk(grid, {48, 85}, :up)
end)
|> Enum.count(fn {_, v} -> v == "o" end)
|> Kernel.+(1)
|> IO.inspect()

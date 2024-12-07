defmodule Solution do
  defp nd(:left), do: :up
  defp nd(:up), do: :right
  defp nd(:right), do: :down
  defp nd(:down), do: :left

  def all_dirs(grid, cell, transform_func) do
    next_cell = transform_func.(cell)
    dirs = List.wrap(Map.get(grid, cell))

    cond do
      dirs == [] -> []
      "#" in dirs -> dirs
      true -> dirs ++ all_dirs(grid, next_cell, transform_func)
    end
  end

  def all_dirs_up(grid, cell), do: all_dirs(grid, cell, fn {r, c} -> {r - 1, c} end)
  def all_dirs_right(grid, cell), do: all_dirs(grid, cell, fn {r, c} -> {r, c + 1} end)
  def all_dirs_down(grid, cell), do: all_dirs(grid, cell, fn {r, c} -> {r + 1, c} end)
  def all_dirs_left(grid, cell), do: all_dirs(grid, cell, fn {r, c} -> {r, c - 1} end)

  defp update_grid(grid, cell, dir) do
    grid
    |> Map.update(cell, [dir], fn existing -> [dir | List.wrap(existing)] end)
  end

  def walk2(grid, {r, c} = cell, :left = dir, options) do
    next_cell = {r, c - 1}

    [a | _] = grid |> all_dirs_up(cell) |> Enum.reverse()

    options =
      if a == "#" do
        Map.put(options, next_cell, 1)
      else
        options
      end

    case Map.get(grid, next_cell) do
      "#" -> grid |> update_grid(cell, dir) |> walk2(cell, nd(dir), options)
      nil -> options
      _ -> grid |> update_grid(cell, dir) |> walk2(next_cell, dir, options)
    end
  end

  def walk2(grid, {r, c} = cell, :up = dir, options) do
    next_cell = {r - 1, c}

    [a | _] = grid |> all_dirs_up(cell) |> Enum.reverse()

    options =
      if a == "#" do
        Map.put(options, next_cell, 1)
      else
        options
      end

    case Map.get(grid, next_cell) do
      "#" -> grid |> update_grid(cell, dir) |> walk2(cell, nd(dir), options)
      nil -> options
      _ -> grid |> update_grid(cell, dir) |> walk2(next_cell, dir, options)
    end
  end

  def walk2(grid, {r, c} = cell, :right = dir, options) do
    next_cell = {r, c + 1}

    [a | _] = grid |> all_dirs_up(cell) |> Enum.reverse()

    options =
      if a == "#" do
        Map.put(options, next_cell, 1)
      else
        options
      end

    case Map.get(grid, next_cell) do
      "#" -> grid |> update_grid(cell, dir) |> walk2(cell, nd(dir), options)
      nil -> options
      _ -> grid |> update_grid(cell, dir) |> walk2(next_cell, dir, options)
    end
  end

  def walk2(grid, {r, c} = cell, :down = dir, options) do
    next_cell = {r + 1, c}

    [a | _] = grid |> all_dirs_up(cell) |> Enum.reverse()

    options =
      if a == "#" do
        Map.put(options, next_cell, 1)
      else
        options
      end

    case Map.get(grid, next_cell) do
      "#" -> grid |> update_grid(cell, dir) |> walk2(cell, nd(dir), options)
      nil -> options
      _ -> grid |> update_grid(cell, dir) |> walk2(next_cell, dir, options)
    end
  end
end

"../input.txt"
|> File.read!()

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
|> String.split("\n", trim: true)
|> then(fn lines ->
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
  # grid |> Map.get({48, 85}) |> IO.inspect()
  # Solution.walk2(grid, {48, 85}, :up, %{})
  Solution.walk2(grid, {6, 4}, :up, %{})
end)
|> IO.inspect()
|> Map.values()
|> Enum.sum()
|> IO.inspect()

# 1837 nope
# 1996
# 874 too low

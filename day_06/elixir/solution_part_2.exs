defmodule Solution do
  def walk(grid, {r, c} = cell, :up = direction, hist, loops) do
    next_cell = {r - 1, c}

    # Map.get(grid, {r, c + 1}) == "o" and 

    hist =
      if Map.get(grid, {r, c - 1}) == "#" do
        Map.update(hist, :left, [r], &[r | &1])
      else
        hist
      end

    case Map.get(grid, next_cell) do
      "#" ->
        grid
        |> Map.put(cell, "o")
        |> walk(cell, :right, Map.update(hist, :up, [c], &[c | &1]), loops)

      nil ->
        loops

      _ ->
        loops =
          if r in Map.get(hist, :right, []) do
            Map.put(loops, next_cell, 1)
          else
            loops
          end

        grid |> Map.put(cell, "o") |> walk(next_cell, direction, hist, loops)
    end
  end

  def walk(grid, {r, c} = cell, :right = direction, hist, loops) do
    next_cell = {r, c + 1}

    hist =
      if Map.get(grid, {r - 1, c}) == "#" do
        Map.update(hist, :up, [c], &[c | &1])
      else
        hist
      end

    case Map.get(grid, next_cell) do
      "#" ->
        grid
        |> Map.put(cell, "o")
        |> walk(cell, :down, Map.update(hist, :right, [r], &[r | &1]), loops)

      nil ->
        loops

      _ ->
        loops =
          if c in Map.get(hist, :down, []) do
            Map.put(loops, next_cell, 1)
          else
            loops
          end

        grid |> Map.put(cell, "o") |> walk(next_cell, direction, hist, loops)
    end
  end

  def walk(grid, {r, c} = cell, :down = direction, hist, loops) do
    next_cell = {r + 1, c}

    hist =
      if Map.get(grid, {r, c + 1}) == "#" do
        Map.update(hist, :right, [r], &[r | &1])
      else
        hist
      end

    case Map.get(grid, next_cell) do
      "#" ->
        grid
        |> Map.put(cell, "o")
        |> walk(cell, :left, Map.update(hist, :down, [c], &[c | &1]), loops)

      nil ->
        loops

      _ ->
        loops =
          if r in Map.get(hist, :left, []) do
            Map.put(loops, next_cell, 1)
          else
            loops
          end

        grid |> Map.put(cell, "o") |> walk(next_cell, direction, hist, loops)
    end
  end

  def walk(grid, {r, c} = cell, :left = direction, hist, loops) do
    next_cell = {r, c - 1}

    hist =
      if Map.get(grid, {r + 1, c}) == "#" do
        Map.update(hist, :down, [c], &[c | &1])
      else
        hist
      end

    case Map.get(grid, next_cell) do
      "#" ->
        grid
        |> Map.put(cell, "o")
        |> walk(cell, :up, Map.update(hist, :left, [r], &[r | &1]), loops)

      nil ->
        loops

      _ ->
        loops =
          if c in Map.get(hist, :up, []) do
            Map.put(loops, next_cell, 1)
          else
            loops
          end

        grid |> Map.put(cell, "o") |> walk(next_cell, direction, hist, loops)
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
  Solution.walk(grid, {6, 4}, :up, %{}, %{})
  # Solution.walk(grid, {48, 85}, :up, %{}, %{})
end)
|> IO.inspect()
|> Map.values()
|> Enum.sum()
|> IO.inspect()

# 1837 nope
# 1996
# 874 too low

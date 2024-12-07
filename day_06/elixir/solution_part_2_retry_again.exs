# start = {6, 4}
start = {48, 85}

input = "../input.txt" |> File.read!()

# input = """
# ....#.....
# .........#
# ..........
# ..#.......
# .......#..
# ..........
# .#..^.....
# ........#.
# #.........
# ......#...
# """

defmodule Solution do
  # @max 100
  @max 50_000

  def walk(grid, _cell, _direction, @max) do
    :max
  end

  def walk(grid, {r, c} = cell, :up = direction, count) do
    next_cell = {r - 1, c}

    case Map.get(grid, next_cell) do
      "#" ->
        grid |> walk(cell, :right, count)

      nil ->
        grid

      _ ->
        grid
        |> Map.update(cell, [direction], &[direction | List.wrap(&1)])
        |> walk(next_cell, direction, count + 1)
    end
  end

  def walk(grid, {r, c} = cell, :right = direction, count) do
    next_cell = {r, c + 1}

    case Map.get(grid, next_cell) do
      "#" ->
        grid |> walk(cell, :down, count)

      nil ->
        grid

      _ ->
        grid
        |> Map.update(cell, [direction], &[direction | List.wrap(&1)])
        |> walk(next_cell, direction, count + 1)
    end
  end

  def walk(grid, {r, c} = cell, :down = direction, count) do
    next_cell = {r + 1, c}

    case Map.get(grid, next_cell) do
      "#" ->
        grid |> walk(cell, :left, count)

      nil ->
        grid

      _ ->
        grid
        |> Map.update(cell, [direction], &[direction | List.wrap(&1)])
        |> walk(next_cell, direction, count + 1)
    end
  end

  def walk(grid, {r, c} = cell, :left = direction, count) do
    next_cell = {r, c - 1}

    case Map.get(grid, next_cell) do
      "#" ->
        grid |> walk(cell, :up, count)

      nil ->
        grid

      _ ->
        grid
        |> Map.update(cell, [direction], &[direction | List.wrap(&1)])
        |> walk(next_cell, direction, count + 1)
    end
  end
end

input
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
  grid
  |> Enum.reduce(0, fn {pos, _}, sum ->
    if pos == start do
      sum
    else
      grid
      |> Map.put(pos, "#")
      |> Solution.walk(start, :up, 0)
      |> then(fn
        :max -> sum + 1
        _ -> sum
      end)
    end
  end)
  |> IO.inspect()

  # Solution.walk(grid, start, :up, 0)
  # |> Map.filter(fn {_, v} ->
  #   Enum.any?(List.wrap(v), fn vv -> vv in [:up, :right, :down, :left] end)
  # end)
  # |> tap(fn vals -> vals |> Enum.count() |> IO.inspect() end)
  # |> tap(fn vals -> vals |> Map.get(start) |> IO.inspect() end)
  # |> Map.to_list()
  # |> Enum.reduce(0, fn {visited_cell, dirs}, sum ->
  #   dirs
  #   |> Enum.filter(fn d -> d in [:up, :right, :down, :left] end)
  #   |> Enum.reduce(sum, fn dir, sum ->
  #     grid
  #     |> Map.put(visited_cell, "#")
  #     |> Solution.walk(start, :up, 0)
  #     |> then(fn
  #       :max -> sum + 1
  #       _ -> sum
  #     end)
  #   end)
  # end)
  # |> IO.inspect()
end)

# 1837 nope
# 1996
# 874 too low
# 1908 nope
# 1907 nope
# 1748 ??

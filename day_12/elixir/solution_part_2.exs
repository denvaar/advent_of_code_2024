defmodule Plots do
  defmodule Grid do
    defstruct [:width, :height, :graph]
  end

  def initialize(width, height) do
    0..(width * height - 1)
    |> Enum.reduce(%{}, fn idx, graph ->
      Map.put(graph, idx, {nil, []})
    end)
    |> then(fn graph -> %Grid{width: width, height: height, graph: graph} end)
  end

  def place_letter(%Grid{} = grid, letter, {row, col} = _pos) do
    grid_idx = row * grid.width + col

    neighbors =
      grid_idx
      |> all_possible_neighbors(grid.width, grid.height)
      |> Enum.filter(fn n ->
        grid.graph
        |> Map.get(n)
        |> elem(0)
        |> Kernel.==(letter)
      end)

    grid.graph
    |> Map.put(grid_idx, {letter, neighbors})
    |> then(fn graph ->
      grid = %Grid{grid | graph: graph}
      %Grid{grid | graph: sync_neighbors(grid, grid_idx, letter)}
    end)
  end

  def adjacent_grid_vertices(%Grid{height: height, width: width}, idx) do
    [
      _above = if(idx - width >= 0, do: idx - width, else: -1),
      _below = if(idx + width < width * height, do: idx + width, else: -1),
      _left = if(rem(idx, width) > 0, do: idx - 1, else: -1),
      _right = if(rem(idx + 1, width) > 0, do: idx + 1, else: -1)
    ]
  end

  defp all_possible_neighbors(idx, width, height) do
    []
    |> add_left_neighbor(idx, {width, height})
    |> add_top_neighbor(idx, {width, height})
    |> add_right_neighbor(idx, {width, height})
    |> add_bottom_neighbor(idx, {width, height})
  end

  defp sync_neighbors(grid, idx, letter) do
    idx
    |> all_possible_neighbors(grid.width, grid.height)
    |> Enum.reduce(grid.graph, fn n, graph ->
      Map.update!(graph, n, fn
        {^letter, neighbors} ->
          neighbors =
            neighbors
            |> MapSet.new()
            |> MapSet.put(idx)
            |> MapSet.to_list()

          {letter, neighbors}

        {_different_letter, _neighbors} = val ->
          val
      end)
    end)
  end

  def count_corners(%Grid{} = grid, component_vertices) do
    component_vertices
    |> Enum.map(fn v ->
      {letter, _neighbors} = Map.get(grid.graph, v)

      [
        single?(grid, v, letter),
        single_top?(grid, v, letter),
        single_bottom?(grid, v, letter),
        single_left?(grid, v, letter),
        single_right?(grid, v, letter),
        outter_bottom_left_corner?(grid, v, letter),
        outter_bottom_right_corner?(grid, v, letter),
        outter_top_left_corner?(grid, v, letter),
        outter_top_right_corner?(grid, v, letter),
        inner_top_left_corner?(grid, v, letter),
        inner_top_right_corner?(grid, v, letter),
        inner_bottom_right_corner?(grid, v, letter),
        inner_bottom_left_corner?(grid, v, letter)
      ]
      |> List.flatten()
      |> Enum.count(& &1)
    end)
    |> Enum.sum()
  end

  defp single?(%Grid{} = grid, v, letter) do
    grid
    |> adjacent_grid_vertices(v)
    |> Enum.map(&elem(Map.get(grid.graph, &1, {nil}), 0))
    |> Enum.all?(&(&1 != letter))
    |> then(fn
      true -> [true, true, true, true]
      false -> false
    end)
  end

  defp single_top?(%Grid{} = grid, v, letter) do
    [top, below, left, right] =
      grid
      |> adjacent_grid_vertices(v)
      |> Enum.map(&elem(Map.get(grid.graph, &1, {nil}), 0))

    [
      _diff_top = top != letter,
      _same_bottom = below == letter,
      _diff_right = right != letter,
      _diff_left = left != letter
    ]
    |> Enum.all?()
    |> then(fn
      true -> [true, true]
      false -> false
    end)
  end

  defp single_bottom?(%Grid{} = grid, v, letter) do
    [top, below, left, right] =
      grid
      |> adjacent_grid_vertices(v)
      |> Enum.map(&elem(Map.get(grid.graph, &1, {nil}), 0))

    [
      _same_top = top == letter,
      _diff_bottom = below != letter,
      _diff_right = right != letter,
      _diff_left = left != letter
    ]
    |> Enum.all?()
    |> then(fn
      true -> [true, true]
      false -> false
    end)
  end

  defp single_left?(%Grid{} = grid, v, letter) do
    [top, below, left, right] =
      grid
      |> adjacent_grid_vertices(v)
      |> Enum.map(&elem(Map.get(grid.graph, &1, {nil}), 0))

    [
      _diff_top = top != letter,
      _diff_bottom = below != letter,
      _same_right = right == letter,
      _diff_left = left != letter
    ]
    |> Enum.all?()
    |> then(fn
      true -> [true, true]
      false -> false
    end)
  end

  defp single_right?(%Grid{} = grid, v, letter) do
    [top, below, left, right] =
      grid
      |> adjacent_grid_vertices(v)
      |> Enum.map(&elem(Map.get(grid.graph, &1, {nil}), 0))

    [
      _diff_top = top != letter,
      _diff_bottom = below != letter,
      _diff_right = right != letter,
      _same_left = left == letter
    ]
    |> Enum.all?()
    |> then(fn
      true -> [true, true]
      false -> false
    end)
  end

  defp outter_bottom_left_corner?(%Grid{} = grid, v, letter) do
    [top, below, left, right] =
      grid
      |> adjacent_grid_vertices(v)
      |> Enum.map(&elem(Map.get(grid.graph, &1, {nil}), 0))

    [
      _same_top = top == letter,
      _same_right = right == letter,
      _diff_left = left != letter,
      _diff_bottom = below != letter
    ]
    |> Enum.all?()
  end

  defp outter_bottom_right_corner?(%Grid{} = grid, v, letter) do
    [top, below, left, right] =
      grid
      |> adjacent_grid_vertices(v)
      |> Enum.map(&elem(Map.get(grid.graph, &1, {nil}), 0))

    [
      _same_top = top == letter,
      _diff_right = right != letter,
      _same_left = left == letter,
      _diff_bottom = below != letter
    ]
    |> Enum.all?()
  end

  defp outter_top_left_corner?(%Grid{} = grid, v, letter) do
    [top, below, left, right] =
      grid
      |> adjacent_grid_vertices(v)
      |> Enum.map(&elem(Map.get(grid.graph, &1, {nil}), 0))

    [
      _diff_top = top != letter,
      _same_right = right == letter,
      _diff_left = left != letter,
      _same_bottom = below == letter
    ]
    |> Enum.all?()
  end

  defp outter_top_right_corner?(%Grid{} = grid, v, letter) do
    [top, below, left, right] =
      grid
      |> adjacent_grid_vertices(v)
      |> Enum.map(&elem(Map.get(grid.graph, &1, {nil}), 0))

    [
      _diff_top = top != letter,
      _diff_right = right != letter,
      _same_left = left == letter,
      _same_bottom = below == letter
    ]
    |> Enum.all?()
  end

  defp inner_top_left_corner?(%Grid{} = grid, v, letter) do
    [kitty, _top, below, _left, right] =
      grid
      |> adjacent_grid_vertices(v)
      |> then(fn
        [_, nil, _, _] -> [v, v, v, v, v]
        [_, below, _, _] = vs -> [below + 1 | vs]
      end)
      |> Enum.map(&elem(Map.get(grid.graph, &1, {nil}), 0))

    [
      _diff_right = right == letter,
      _same_bottom = below == letter,
      _diff_kitty = kitty != letter
    ]
    |> Enum.all?()
  end

  defp inner_top_right_corner?(%Grid{} = grid, v, letter) do
    [kitty, _top, below, left, _right] =
      grid
      |> adjacent_grid_vertices(v)
      |> then(fn
        [_, nil, _, _] -> [v, v, v, v, v]
        [_, below, _, _] = vs -> [below - 1 | vs]
      end)
      |> Enum.map(&elem(Map.get(grid.graph, &1, {nil}), 0))

    [
      _same_left = left == letter,
      _same_bottom = below == letter,
      _diff_kitty = kitty != letter
    ]
    |> Enum.all?()
  end

  defp inner_bottom_right_corner?(%Grid{} = grid, v, letter) do
    [kitty, top, _below, left, _right] =
      grid
      |> adjacent_grid_vertices(v)
      |> then(fn
        [nil, _, _, _] -> [v, v, v, v, v]
        [top, _, _, _] = vs -> [top - 1 | vs]
      end)
      |> Enum.map(&elem(Map.get(grid.graph, &1, {nil}), 0))

    [
      _same_left = left == letter,
      _same_top = top == letter,
      _diff_kitty = kitty != letter
    ]
    |> Enum.all?()
  end

  defp inner_bottom_left_corner?(%Grid{} = grid, v, letter) do
    [kitty, top, _below, _left, right] =
      grid
      |> adjacent_grid_vertices(v)
      |> then(fn
        [nil, _, _, _] -> [v, v, v, v, v]
        [top, _, _, _] = vs -> [top + 1 | vs]
      end)
      |> Enum.map(&elem(Map.get(grid.graph, &1, {nil}), 0))

    [
      _same_right = right == letter,
      _same_top = top == letter,
      _diff_kitty = kitty != letter
    ]
    |> Enum.all?()
  end

  def all_connected_components(%Grid{} = grid) do
    grid.graph
    |> Map.keys()
    |> Enum.reduce({MapSet.new(), [MapSet.new()]}, fn v, {seen, components} ->
      case MapSet.member?(seen, v) do
        true ->
          {seen, components}

        false ->
          {seen, current_set} = explore([v], seen, MapSet.new(), grid.graph)
          {seen, [current_set | components]}
      end
    end)
    |> then(fn {_seen, components} ->
      components
      |> Enum.filter(&Enum.any?/1)
      |> Enum.map(&MapSet.to_list/1)
    end)
  end

  defp explore([], seen, current_set, _graph) do
    {seen, current_set}
  end

  defp explore([v | to_explore], seen, current_set, graph) do
    case MapSet.member?(seen, v) do
      true ->
        explore(to_explore, seen, current_set, graph)

      false ->
        seen = MapSet.put(seen, v)
        current_set = MapSet.put(current_set, v)
        neighbors = neighbors(graph, v)

        explore(neighbors ++ to_explore, seen, current_set, graph)
    end
  end

  def neighbors(graph, v) do
    graph
    |> Map.get(v)
    |> elem(1)
  end

  defp add_left_neighbor(neighbors, idx, {width, _height}) do
    case rem(idx, width) do
      0 -> neighbors
      _non_zero -> [idx - 1 | neighbors]
    end
  end

  defp add_right_neighbor(neighbors, idx, {width, _height}) do
    case rem(idx + 1, width) do
      0 -> neighbors
      _non_zero -> [idx + 1 | neighbors]
    end
  end

  defp add_top_neighbor(neighbors, idx, {width, _height}) do
    case idx - width do
      neighbor_idx when neighbor_idx >= 0 -> [neighbor_idx | neighbors]
      _neighbor_idx -> neighbors
    end
  end

  defp add_bottom_neighbor(neighbors, idx, {width, height}) do
    case idx + width do
      neighbor_idx when neighbor_idx < width * height -> [neighbor_idx | neighbors]
      _neighbor_idx -> neighbors
    end
  end
end

"../input.txt"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.with_index()
|> Enum.reduce(%{}, fn {line, row_idx}, raw_grid ->
  line
  |> String.split("", trim: true)
  |> Enum.with_index()
  |> Enum.reduce(raw_grid, fn {char, col_idx}, raw_grid ->
    Map.put(raw_grid, {row_idx, col_idx}, char)
  end)
end)
|> then(fn raw_grid ->
  width = Enum.map(raw_grid, fn {{_r, c}, _v} -> c end) |> Enum.max()
  height = Enum.map(raw_grid, fn {{r, _c}, _v} -> r end) |> Enum.max()

  grid =
    Enum.reduce(
      raw_grid,
      Plots.initialize(width + 1, height + 1),
      fn {pos, letter}, grid -> Plots.place_letter(grid, letter, pos) end
    )

  grid
  |> Plots.all_connected_components()
  |> Enum.reduce(0, fn component_vertices, total ->
    area = length(component_vertices)
    corner_count = Plots.count_corners(grid, component_vertices)

    total + corner_count * area
  end)
end)
|> IO.inspect(limit: :infinity, charlists: :as_lists)

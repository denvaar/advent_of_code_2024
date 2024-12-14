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
    perimiter =
      Enum.reduce(component_vertices, 0, fn v, perimiter ->
        case Map.get(grid.graph, v) do
          {_letter, neighbors} when length(neighbors) < 4 -> perimiter + (4 - length(neighbors))
          {_letter, _neighbors} -> perimiter
        end
      end)

    total + perimiter * length(component_vertices)
  end)
end)
|> IO.inspect(limit: :infinity, charlists: :as_lists)

defmodule Solution do
  defmodule Grid do
    def at(grid, row, col) do
      grid
      |> elem(row)
      |> elem(col)
    end

    defp at(grid, row, col, "^"), do: at(grid, row - 1, col)
    defp at(grid, row, col, ">"), do: at(grid, row, col + 1)
    defp at(grid, row, col, "v"), do: at(grid, row + 1, col)
    defp at(grid, row, col, "<"), do: at(grid, row, col - 1)

    defp next_position(row, col, direction) do
      case direction do
        "^" -> {row - 1, col}
        ">" -> {row, col + 1}
        "v" -> {row + 1, col}
        "<" -> {row, col - 1}
      end
    end

    defp update_cell(grid, row, col, val) do
      updated_row =
        grid
        |> elem(row)
        |> put_elem(col, val)

      put_elem(grid, row, updated_row)
    end

    defp horizontal_push(grid, row, col, direction, vals \\ []) do
      {t_row, t_col} = next_position(row, col, direction)

      case at(grid, row, col, direction) do
        "." = _target ->
          [{t_row, t_col} | vals]

        "#" = _target ->
          []

        "]" = _target ->
          horizontal_push(grid, t_row, t_col, direction, [{t_row, t_col} | vals])

        "[" = _target ->
          horizontal_push(grid, t_row, t_col, direction, [{t_row, t_col} | vals])
      end
    end

    defp update_cells_horizontally(moves, grid, original_row, original_col, direction) do
      {val_1, val_2} =
        if direction == "<" do
          {"[", "]"}
        else
          {"]", "["}
        end

      moves
      |> Enum.chunk_every(2)
      |> Enum.reduce({grid, original_row, original_col}, fn
        [{r1, c1}, {r2, c2}], {grid, _row, _col} ->
          grid = grid |> update_cell(r1, c1, val_1) |> update_cell(r2, c2, val_2)

          {grid, r2, c2}

        [{r1, c1}], {grid, _row, _col} ->
          grid = grid |> update_cell(r1, c1, "@") |> update_cell(original_row, original_col, ".")

          {grid, r1, c1}
      end)
    end

    def vertical_push(grid, row, col, direction, vals \\ []) do
      {t_row, t_col} = next_position(row, col, direction)

      case at(grid, row, col, direction) do
        "]" = _target ->
          right_vals = vertical_push(grid, t_row, t_col, direction, [{t_row, t_col} | vals])

          left_vals =
            vertical_push(grid, t_row, t_col - 1, direction, [{t_row, t_col - 1} | vals])

          if Enum.any?([left_vals, right_vals], &(&1 == [])) do
            []
          else
            right_vals ++ left_vals
          end

        "[" = _target ->
          left_vals = vertical_push(grid, t_row, t_col, direction, [{t_row, t_col} | vals])

          right_vals =
            vertical_push(grid, t_row, t_col + 1, direction, [{t_row, t_col + 1} | vals])

          if Enum.any?([left_vals, right_vals], &(&1 == [])) do
            []
          else
            left_vals ++ right_vals
          end

        "." = _target ->
          vals

        "#" = _target ->
          []
      end
    end

    defp update_cells_vertically([], grid, row, col, _direction), do: {grid, row, col}

    defp update_cells_vertically(positions, grid, row, col, direction) do
      {row_delta, sort_direction} =
        if direction == "^" do
          {-1, :asc}
        else
          {1, :desc}
        end

      positions
      |> Enum.uniq()
      |> List.keysort(0, sort_direction)
      |> Enum.reduce(grid, fn {row, col}, grid ->
        val = at(grid, row, col)

        grid
        |> update_cell(row, col, ".")
        |> update_cell(row + row_delta, col, val)
      end)
      |> then(fn grid ->
        grid =
          grid
          |> update_cell(row, col, ".")
          |> update_cell(row + row_delta, col, "@")

        {grid, row + row_delta, col}
      end)
    end

    def move(grid, row, col, direction) do
      {t_row, t_col} = next_position(row, col, direction)

      case at(grid, row, col, direction) do
        "." = _target ->
          new_grid =
            grid
            |> update_cell(row, col, ".")
            |> update_cell(t_row, t_col, "@")

          {new_grid, t_row, t_col}

        "#" = _target ->
          {grid, row, col}

        target when target in ~w([ ]) and direction in ~w(< >) ->
          grid
          |> horizontal_push(row, col, direction)
          |> update_cells_horizontally(grid, row, col, direction)

        target when target in ~w([ ]) and direction in ~w(^ v) ->
          grid
          |> vertical_push(row, col, direction)
          |> update_cells_vertically(grid, row, col, direction)
      end
    end
  end

  def print_warehouse(grid) do
    grid
    |> Tuple.to_list()
    |> Enum.reduce("", fn row, output ->
      row
      |> Tuple.to_list()
      |> Enum.reduce(output, fn col, output ->
        output <> col
      end)
      |> Kernel.<>("\n")
    end)
    |> IO.puts()
  end

  def process_moves(grid, row, col, moves) do
    moves
    |> Enum.reduce({grid, row, col}, fn direction, {grid, row, col} ->
      # Solution.print_warehouse(grid)
      Solution.Grid.move(grid, row, col, direction)
    end)
    |> then(fn {grid, _, _} -> grid end)
  end

  def sum_box_coordinates(grid, width, height) do
    0..(height - 1)
    |> Enum.reduce(0, fn row, sum ->
      0..(width - 1)
      |> Enum.reduce(sum, fn col, sum ->
        case Solution.Grid.at(grid, row, col) do
          "[" -> sum + (100 * row + col)
          _ -> sum
        end
      end)
    end)
  end
end

"../input.txt"
|> File.read!()
|> String.split("\n\n", trim: true)
|> then(fn [area, moves] ->
  [row | _] = rows = String.split(area, "\n", trim: true)
  width = String.length(row) * 2
  height = Enum.count(rows)

  grid =
    Enum.map(rows, fn row ->
      row
      |> String.split("", trim: true)
      |> Enum.flat_map(fn
        "." -> [".", "."]
        "#" -> ["#", "#"]
        "O" -> ["[", "]"]
        "@" -> ["@", "."]
      end)
      |> List.to_tuple()
    end)
    |> List.to_tuple()

  moves = moves |> String.split("", trim: true) |> Enum.reject(&(&1 == "\n"))

  [width: width, height: height, grid: grid, row: 24, col: 24 * 2, moves: moves]
end)
|> then(fn [width: width, height: height, grid: grid, row: row, col: col, moves: moves] ->
  grid
  |> Solution.process_moves(row, col, moves)
  |> Solution.sum_box_coordinates(width, height)
end)
|> IO.inspect()

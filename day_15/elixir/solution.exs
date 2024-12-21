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

    defp push(grid, row, col, direction, vals \\ []) do
      case at(grid, row, col, direction) do
        "." ->
          [next_position(row, col, direction) | vals]

        "#" ->
          []

        "O" ->
          {t_row, t_col} = next_position(row, col, direction)

          push(grid, t_row, t_col, direction, [{t_row, t_col} | vals])
      end
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

        "O" = _target ->
          grid
          |> push(row, col, direction)
          |> Enum.reduce({grid, row, col}, fn {r, c}, {grid, _row, _col} ->
            grid = update_cell(grid, r, c, "O")
            {grid, r, c}
          end)
          |> then(fn {grid, r, c} ->
            new_grid =
              grid
              |> update_cell(row, col, ".")
              |> update_cell(r, c, "@")

            {new_grid, r, c}
          end)
      end
    end
  end

  def process_moves(grid, row, col, moves) do
    moves
    |> Enum.reduce({grid, row, col}, fn direction, {grid, row, col} ->
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
          "O" -> sum + (100 * row + col)
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
  width = String.length(row)
  height = Enum.count(rows)

  grid =
    Enum.map(rows, fn row ->
      row
      |> String.split("", trim: true)
      |> List.to_tuple()
    end)
    |> List.to_tuple()

  moves = moves |> String.split("", trim: true) |> Enum.reject(&(&1 == "\n"))

  [width: width, height: height, grid: grid, row: 24, col: 24, moves: moves]
end)
|> then(fn [width: width, height: height, grid: grid, row: row, col: col, moves: moves] ->
  grid
  |> Solution.process_moves(row, col, moves)
  |> Solution.sum_box_coordinates(width, height)
end)
|> IO.inspect()

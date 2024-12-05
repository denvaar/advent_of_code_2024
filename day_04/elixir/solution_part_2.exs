defmodule Solution do
  def top_left_to_bottom_right?(grid, row, col) do
    top_left_letter =
      if row - 1 >= 0 do
        grid |> Enum.at(row - 1, []) |> Enum.at(col - 1)
      else
        nil
      end

    bottom_right_letter = grid |> Enum.at(row + 1, []) |> Enum.at(col + 1)

    (top_left_letter == "M" and bottom_right_letter == "S") or
      (top_left_letter == "S" and bottom_right_letter == "M")
  end

  def top_right_to_bottom_left?(grid, row, col) do
    top_right_letter =
      if row - 1 >= 0 do
        grid |> Enum.at(row - 1, []) |> Enum.at(col + 1)
      else
        nil
      end

    bottom_left_letter =
      if col - 1 >= 0 do
        grid |> Enum.at(row + 1, []) |> Enum.at(col - 1)
      else
        nil
      end

    (top_right_letter == "M" and bottom_left_letter == "S") or
      (top_right_letter == "S" and bottom_left_letter == "M")
  end
end

grid =
  "../input.txt"
  |> File.read!()
  |> String.split("", trim: true)
  |> Enum.reject(&(&1 == "\n"))
  |> Enum.chunk_every(140)

# 2051 too high
# 1538 not right
# 1035 too low
grid
|> List.flatten()
|> Enum.with_index()
|> Enum.reduce(0, fn
  {"A", idx}, sum ->
    row = div(idx, 140)
    col = rem(idx, 140)

    if Solution.top_left_to_bottom_right?(grid, row, col) and
         Solution.top_right_to_bottom_left?(grid, row, col) do
      sum + 1
    else
      sum
    end

  {_, _idx}, sum ->
    sum
end)
|> IO.inspect()

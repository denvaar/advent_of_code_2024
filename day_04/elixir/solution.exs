defmodule Solution do
  def count_horizontal(grid) do
    left_to_right_count = Enum.reduce(grid, 0, fn line, count -> count + parse(line, "", 0) end)

    right_to_left_count =
      Enum.reduce(grid, 0, fn line, count ->
        line
        |> Enum.reverse()
        |> parse("", 0)
        |> Kernel.+(count)
      end)

    left_to_right_count + right_to_left_count
  end

  def count_vertical(grid) do
    top_to_bottom =
      grid
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.reduce(0, fn col, count -> count + parse(col, "", 0) end)

    bottom_to_top =
      grid
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.reduce(0, fn col, count -> count + parse(Enum.reverse(col), "", 0) end)

    bottom_to_top + top_to_bottom
  end

  def count_diagonal(grid) do
    top_right =
      0..139
      |> Enum.map(fn n ->
        0..139
        |> Enum.zip(n..139)
        |> Enum.reduce([], fn {idx1, idx2}, acc ->
          [grid |> Enum.at(idx1) |> Enum.at(idx2) | acc]
        end)
      end)

    top_right_inv =
      0..139
      |> Enum.map(fn n ->
        0..139
        |> Enum.zip(n..0)
        |> Enum.reduce([], fn {idx1, idx2}, acc ->
          [grid |> Enum.at(idx1) |> Enum.at(idx2) | acc]
        end)
      end)

    bottom_left =
      1..139
      |> Enum.map(fn n ->
        n..139
        |> Enum.zip(0..139)
        |> Enum.reduce([], fn {idx1, idx2}, acc ->
          [grid |> Enum.at(idx1) |> Enum.at(idx2) | acc]
        end)
      end)

    bottom_left_inv =
      1..139
      |> Enum.map(fn n ->
        n..139
        |> Enum.zip(139..0)
        |> Enum.reduce([], fn {idx1, idx2}, acc ->
          [grid |> Enum.at(idx1) |> Enum.at(idx2) | acc]
        end)
      end)

    top_right_sum =
      top_right
      |> Enum.reduce(0, fn diag, count -> count + parse(diag, "", 0) end)
      |> Kernel.+(
        Enum.reduce(top_right, 0, fn diag, count ->
          diag
          |> Enum.reverse()
          |> parse("", 0)
          |> Kernel.+(count)
        end)
      )

    bottom_left_sum =
      bottom_left
      |> Enum.reduce(0, fn diag, count -> count + parse(diag, "", 0) end)
      |> Kernel.+(
        Enum.reduce(bottom_left, 0, fn diag, count ->
          diag
          |> Enum.reverse()
          |> parse("", 0)
          |> Kernel.+(count)
        end)
      )

    bottom_left_inv_sum =
      bottom_left_inv
      |> Enum.reduce(0, fn diag, count -> count + parse(diag, "", 0) end)
      |> Kernel.+(
        Enum.reduce(bottom_left_inv, 0, fn diag, count ->
          diag
          |> Enum.reverse()
          |> parse("", 0)
          |> Kernel.+(count)
        end)
      )

    top_right_inv_sum =
      top_right_inv
      |> Enum.reduce(0, fn diag, count -> count + parse(diag, "", 0) end)
      |> Kernel.+(
        Enum.reduce(top_right_inv, 0, fn diag, count ->
          diag
          |> Enum.reverse()
          |> parse("", 0)
          |> Kernel.+(count)
        end)
      )

    top_right_sum + bottom_left_sum + bottom_left_inv_sum + top_right_inv_sum
  end

  def parse(["X" | chars], _cache, sum), do: parse(chars, "X", sum)
  def parse(["M" | chars], "X", sum), do: parse(chars, "XM", sum)
  def parse(["A" | chars], "XM", sum), do: parse(chars, "XMA", sum)
  def parse(["S" | chars], "XMA", sum), do: parse(chars, "", sum + 1)
  def parse([_ | chars], _cache, sum), do: parse(chars, "", sum)
  def parse([], _cache, sum), do: sum
end

grid =
  "../input.txt"
  |> File.read!()
  |> String.split("", trim: true)
  |> Enum.reject(&(&1 == "\n"))
  |> Enum.chunk_every(140)

[
  Solution.count_diagonal(grid),
  Solution.count_horizontal(grid),
  Solution.count_vertical(grid)
]
|> Enum.sum()
|> IO.inspect()

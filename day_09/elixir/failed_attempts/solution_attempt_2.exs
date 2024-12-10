defmodule Solution do
  def sum2(t, max, total \\ 0, idx \\ 0)

  def sum2(_t, max, total, idx) when idx == max, do: total

  def sum2(t, max, total, idx) do
    case elem(t, idx) do
      "." -> sum2(t, max, total, idx + 1)
      n -> sum2(t, max, total + idx * String.to_integer(n), idx + 1)
    end
  end

  def compact2(t, l_idx, r_idx, len, width) do
    # t
    # |> Tuple.to_list()
    # |> Enum.join()
    # |> IO.inspect()

    l_idx = walk_right(t, l_idx, len)
    r_idx = walk_left(t, r_idx)

    if l_idx < r_idx do
      assign(t, l_idx, r_idx, width)

      t
      |> put_elem(l_idx, elem(t, r_idx))
      |> put_elem(r_idx, ".")
      |> compact2(l_idx + 1, r_idx - 1, len, width)
    else
      t
    end
  end

  defp assign(t, _l_idx, _r_idx, _len, 0), do: t

  defp assign(t, l_idx, r_idx, len, offset) do
    t =
      t
      |> put_elem(l_idx, elem(t, r_idx))
      |> put_elem(r_idx, ".")

    l_idx = walk_right(t, l_idx, len)
    assign(t, l_idx, r_idx - 1, len, offset - 1)
  end

  defp get_digits(n) do
    String.length("#{n - 1}")
  end

  defp walk_right(t, idx, idx), do: idx

  defp walk_right(t, idx, limit) do
    case elem(t, idx) do
      "." -> idx
      _ -> walk_right(t, idx + 1, limit)
    end
  end

  defp walk_left(t, idx) do
    # from the back
    case elem(t, idx) do
      "." -> walk_left(t, idx - 1)
      _ -> idx
    end
  end
end

"../input.txt"
|> File.read!()

"222222222222222222222222"

"233313312141413140233"
|> String.split("", trim: true)
|> Enum.reject(fn
  "\n" -> true
  _ -> false
end)
|> Enum.map(&String.to_integer/1)
|> Enum.chunk_every(2)
|> Enum.with_index()
|> Enum.reduce("", fn
  {[n_block], idx}, acc ->
    digits = "#{idx}" |> String.length()

    {acc
     |> Kernel.<>(
       idx
       |> List.duplicate(n_block)
       |> Enum.join()
     ), digits}

  {[n_block, freesp], idx}, acc ->
    digits = "#{idx}" |> String.length()

    s1 =
      idx
      |> List.duplicate(n_block)
      |> Enum.join()

    s2 =
      "."
      |> List.duplicate(freesp)
      |> Enum.join()

    {acc <> s1 <> s2, digits}
end)
|> IO.inspect()
|> then(fn {s, digits} ->
  s = String.split(s, "", trim: true)

  len = Enum.count(s)

  s
  |> List.to_tuple()
  |> Solution.compact2(0, len - 1, len - 1, digits)
  |> tap(fn t ->
    t
    |> Tuple.to_list()
    |> Enum.join()
    |> then(fn n ->
      File.write!("/Users/denvaar/outp", "#{n}")
    end)
  end)
  |> Solution.sum2(len - 1)
end)
|> IO.inspect()

defmodule Solution do
  require Integer

  def blink(_stone, 0, count, cache), do: {count, cache}
  def blink(0, times, count, cache), do: blink(1, times - 1, count, cache)
  def blink(1, times, count, cache), do: blink(2024, times - 1, count, cache)

  def blink(stone, times, count, cache) do
    cached_count = Map.get(cache, {stone, times})

    if is_nil(cached_count) do
      if even_number_of_digits?(stone) do
        stone
        |> Integer.digits()
        |> then(fn digits ->
          digits
          |> Enum.chunk_every(div(Enum.count(digits), 2))
          |> then(fn [s1, s2] ->
            s1 = s1 |> Integer.undigits()
            s2 = s2 |> Integer.undigits()

            {c1, cache1} = blink(s1, times - 1, 1, cache)
            {c2, cache2} = blink(s2, times - 1, 1, cache1)

            {c1 + c2, Map.put(cache2, {stone, times}, c1 + c2)}
          end)
        end)
      else
        blink(stone * 2024, times - 1, count, cache)
      end
    else
      {cached_count, cache}
    end
  end

  def even_number_of_digits?(n) do
    n
    |> :math.log10()
    |> :math.floor()
    |> trunc()
    |> Kernel.+(1)
    |> rem(2)
    |> Kernel.==(0)
  end
end

"../input.txt"
|> File.read!()
|> String.split("\n", trim: true)
|> List.first()
|> String.split(" ", trim: true)
|> Enum.map(&String.to_integer/1)
|> Enum.reduce({0, %{}}, fn stone, {count, cache} ->
  {co, ca} = Solution.blink(stone, 75, 0, cache)
  {count + co, Map.merge(cache, ca)}
end)
|> elem(0)
|> IO.inspect()

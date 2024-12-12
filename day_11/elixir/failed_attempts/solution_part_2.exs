defmodule Solution do
  require Integer

  # {stones, stone_count, _skip_steps}
  @cache %{
    0 => {[2, 0, 2, 4], 4, 4},
    1 => {[2, 0, 2, 4], 4, 3},
    2 => {[4, 0, 4, 8], 4, 3},
    3 => {[6, 0, 7, 2], 4, 3},
    4 => {[8, 0, 9, 6], 4, 3},
    5 => {[2, 0, 4, 8, 2, 8, 8, 0], 8, 5},
    6 => {[2, 4, 5, 7, 9, 4, 5, 2], 8, 5},
    7 => {[2, 8, 6, 8, 6, 0, 3, 2], 8, 5},
    8 => {[3, 2, 7, 7, 2, 6, 16_192], 7, 5},
    9 => {[3, 6, 8, 6, 9, 1, 8, 4], 8, 5},
    16_192 => {[3, 2, 7, 7, 2, 6, 16_192], 7, 4}
  }

  def blink(stone, count, 0) do
    if stone == 16192 do
      IO.inspect(stone)
    end

    count
  end

  def blink(stone, count, step) do
    if stone == 16192 do
      IO.inspect(stone)
    end

    count |> IO.inspect(label: "processing #{stone}")

    stone
    |> apply_rules(step)
    |> then(fn {stones, c, s} ->
      stones
      |> Enum.reduce(0, fn stone, _total -> blink(stone, 1 + count, step - s) end)
      |> Kernel.+(c)
      |> IO.inspect(label: "result of #{stone}")

      # |> Kernel.+(count)
    end)
  end

  defp apply_rules(stone, step) when step < 6 do
    cond do
      stone == 0 ->
        {[1], 1, 1}

      stone == 1 ->
        {[2024], 1, 1}

      even_number_of_digits?(stone) ->
        stone
        |> Integer.digits()
        |> then(fn digits ->
          digits
          |> Enum.chunk_every(div(Enum.count(digits), 2))
          |> Enum.map(&Integer.undigits/1)
          |> then(fn stones -> {stones, Enum.count(stones), 1} end)
        end)

      true ->
        {[stone * 2024], 1, 1}
    end
  end

  defp apply_rules(stone, _step) do
    case Map.get(@cache, stone, stone) do
      {_stones, _count, _step_inc} = cache_hit ->
        IO.inspect("cache hit")
        cache_hit

      stone ->
        if even_number_of_digits?(stone) do
          stone
          |> Integer.digits()
          |> then(fn digits ->
            digits
            |> Enum.chunk_every(div(Enum.count(digits), 2))
            |> Enum.map(&Integer.undigits/1)
            |> then(fn stones ->
              {stones, Enum.count(stones), 1}
            end)
          end)
        else
          {[stone * 2024], 1, 1}
        end
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

# defmodule Solution2 do
#   def blink(_stone, 0) do
#     1
#   end
# 
#   def blink(stone, times) do
#     stone
#     |> apply_rules()
#     |> Enum.reduce(0, fn stone, total ->
#       total + blink(stone, times - 1, cache)
#     end)
#   end
# 
#   defp apply_rules("0") do
#     ["1"]
#   end
# 
#   defp apply_rules(stone) do
#     case String.length(stone) do
#       len when rem(len, 2) == 0 ->
#         {s1, s2} = stone |> String.split_at(div(len, 2))
# 
#         [remove_leading_zeros(s1), remove_leading_zeros(s2)]
# 
#       _ ->
#         ["#{String.to_integer(stone) * 2024}"]
#     end
#   end
# 
#   defp remove_leading_zeros("0"), do: "0"
# 
#   defp remove_leading_zeros(<<"0", stone::binary>>) do
#     remove_leading_zeros(stone)
#   end
# 
#   defp remove_leading_zeros(stone), do: stone
# end
# 
# defmodule Solution1 do
#   def blink(stones, 0), do: stones
# 
#   def blink(stones, times) do
#     stones
#     |> apply_rules([])
#     |> blink(times - 1)
#   end
# 
#   defp apply_rules([], output), do: output
# 
#   defp apply_rules(["0" | stones], output) do
#     apply_rules(stones, ["1" | output])
#   end
# 
#   defp apply_rules([stone | stones], output) do
#     case String.length(stone) do
#       len when rem(len, 2) == 0 ->
#         {s1, s2} = stone |> String.split_at(div(len, 2))
# 
#         stones
#         |> apply_rules([remove_leading_zeros(s2), remove_leading_zeros(s1) | output])
# 
#       _ ->
#         apply_rules(stones, ["#{String.to_integer(stone) * 2024}" | output])
#     end
#   end
# 
#   defp remove_leading_zeros("0"), do: "0"
# 
#   defp remove_leading_zeros(<<"0", stone::binary>>) do
#     remove_leading_zeros(stone)
#   end
# 
#   defp remove_leading_zeros(stone), do: stone
# end

# "../input.txt"
# |> File.read!()
# "3 386358 86195 85 1267 3752457 0 741"

"125 17"
|> String.split(" ", trim: true)
|> Enum.map(&String.to_integer/1)
|> Enum.map(fn stone ->
  Solution.blink(stone, 0, 6)
  |> IO.inspect(label: "#{stone}'s count")
end)
|> Enum.sum()
|> IO.inspect(label: "count")

# |> IO.inspect()

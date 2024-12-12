defmodule Solution do
  def blink(stones, 0), do: stones

  def blink(stones, times) do
    stones
    |> apply_rules([])
    |> blink(times - 1)
  end

  defp apply_rules([], output), do: output

  defp apply_rules(["0" | stones], output) do
    apply_rules(stones, ["1" | output])
  end

  defp apply_rules([stone | stones], output) do
    case String.length(stone) do
      len when rem(len, 2) == 0 ->
        {s1, s2} = stone |> String.split_at(div(len, 2))

        stones
        |> apply_rules([remove_leading_zeros(s2), remove_leading_zeros(s1) | output])

      _ ->
        apply_rules(stones, ["#{String.to_integer(stone) * 2024}" | output])
    end
  end

  defp remove_leading_zeros("0"), do: "0"

  defp remove_leading_zeros(<<"0", stone::binary>>) do
    remove_leading_zeros(stone)
  end

  defp remove_leading_zeros(stone), do: stone
end

"../input.txt"
|> File.read!()
|> String.split("\n", trim: true)
|> List.first()
|> then(fn stones ->
  stones
  |> String.split(" ", trim: true)
  |> Solution.blink(25)
  |> Enum.count()
end)
|> IO.inspect()

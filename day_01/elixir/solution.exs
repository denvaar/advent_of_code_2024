"../input.txt"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.reduce({[], []}, fn line, {acc_a, acc_b} ->
  [a, b] = String.split(line, " ", trim: true)
  a = String.to_integer(a)
  b = String.to_integer(b)

  {[a | acc_a], [b | acc_b]}
end)
|> then(fn {a, b} ->
  a
  |> Enum.sort()
  |> Enum.zip(Enum.sort(b))
  |> Enum.reduce(0, fn {n1, n2}, total ->
    abs(n1 - n2) + total
  end)
end)
|> IO.inspect()

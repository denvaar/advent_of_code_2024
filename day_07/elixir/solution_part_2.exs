defmodule Solution do
  def compute?([a, b], n) do
    a + b == n or a * b == n or concat(a, b) == n
  end

  def compute?([a, b | numbs], n) do
    added = a + b
    multiplied = a * b
    concatenated = concat(a, b)

    compute?([added | numbs], n) or compute?([multiplied | numbs], n) or
      compute?([concatenated | numbs], n)
  end

  defp concat(a, b), do: String.to_integer("#{a}#{b}")
end

"../input.txt"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.reduce(0, fn line, acc ->
  [exp_result, numbs] = String.split(line, ": ", trim: true)
  exp_result = String.to_integer(exp_result)

  numbs =
    numbs
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)

  case Solution.compute?(numbs, exp_result) do
    true -> exp_result + acc
    false -> acc
  end
end)
|> IO.inspect()

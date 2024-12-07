defmodule Solution do
  def compute?([a, b], n) do
    a + b == n or a * b == n
  end

  def compute?([a, b | numbs], n) do
    added = a + b
    multiplied = a * b

    compute?([added | numbs], n) or compute?([multiplied | numbs], n)
  end
end

"""
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
"""

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

  {numbs, exp_result}

  case Solution.compute?(numbs, exp_result) do
    true ->
      IO.inspect(exp_result)
      exp_result + acc

    false ->
      acc
  end
end)
|> IO.inspect()

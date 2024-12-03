defmodule Solution do
  @digits ~w(0 1 2 3 4 5 6 7 8 9)

  def parse(characters, cache \\ "", state \\ :begin_mul, exprs \\ [])

  def parse(<<"m", characters::binary>>, _cache, _state, exprs) do
    parse(characters, "m", :begin_mul, exprs)
  end

  def parse(<<"u", characters::binary>>, "m", :begin_mul, exprs) do
    parse(characters, "mu", :begin_mul, exprs)
  end

  def parse(<<"l", characters::binary>>, "mu", :begin_mul, exprs) do
    parse(characters, "mul", :begin_mul, exprs)
  end

  def parse(<<"(", characters::binary>>, "mul", :begin_mul, exprs) do
    parse(characters, "", :first_digits, exprs)
  end

  def parse(<<c::binary-size(1), characters::binary>>, cache, :first_digits, exprs)
      when c in @digits do
    parse(characters, cache <> c, :first_digits, exprs)
  end

  def parse(<<",", characters::binary>>, cache, :first_digits, exprs) do
    parse(characters, cache <> ",", :second_digits, exprs)
  end

  def parse(<<c::binary-size(1), characters::binary>>, cache, :second_digits, exprs)
      when c in @digits do
    parse(characters, cache <> c, :second_digits, exprs)
  end

  def parse(<<")", characters::binary>>, cache, :second_digits, exprs) do
    [a, b] = cache |> String.split(",", trim: true)
    parse(characters, "", :begin_mul, [String.to_integer(a) * String.to_integer(b) | exprs])
  end

  def parse(<<_c::binary-size(1), characters::binary>>, _cache, _state, exprs) do
    parse(characters, "", :begin_mul, exprs)
  end

  def parse("", _cache, _state, exprs) do
    exprs |> Enum.sum()
  end
end

"../input.txt"
|> File.read!()
|> Solution.parse()
|> IO.inspect()

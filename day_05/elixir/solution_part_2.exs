defmodule Solution do
  def fix(updates, rules) do
    # try sorting the updates based on how many dependencies
    # they have. The most should come first.
    IO.inspect({updates, rules})

    updates
    |> Enum.map(fn update ->
      update
      |> Enum.map(fn page ->
        deps =
          rules
          |> Map.get(page, [])
          |> Enum.filter(fn r -> r in update end)

        {page, length(deps)}
      end)
      |> List.keysort(1, :desc)
      |> Enum.map(&elem(&1, 0))
    end)
  end

  def parse_rules(rules) do
    rules
    |> String.split("\n", trim: true)
    |> Enum.map(fn raw_rule ->
      raw_rule
      |> String.split("|", trim: true)
      |> then(fn [x, y] -> {x, y} end)
    end)
    |> Enum.reduce(%{}, fn {x, y}, rules ->
      Map.update(rules, x, [y], fn existing -> [y | existing] end)
    end)
  end

  def parse_updates(updates) do
    updates
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ",", trim: true))
  end
end

"""
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
"""

"../input.txt"
|> File.read!()
|> String.split("\n\n", trim: true)
|> then(fn [rules, updates] ->
  rules = Solution.parse_rules(rules)
  updates = Solution.parse_updates(updates)

  updates
  |> Enum.reject(fn update ->
    1..(length(update) - 1)
    |> Enum.all?(fn idx ->
      {pages, subsequent_pages} = Enum.split(update, idx)
      [page | _] = Enum.reverse(pages)

      subsequent_page_rules = Map.get(rules, page, [])
      Enum.all?(subsequent_pages, fn p -> p in subsequent_page_rules end)
    end)
  end)
  |> Solution.fix(rules)
end)
|> IO.inspect()
|> Enum.map(fn update ->
  middle_idx = div(length(update), 2)
  {_, [page | _]} = Enum.split(update, middle_idx)
  String.to_integer(page)
end)
|> Enum.sum()
|> IO.inspect()

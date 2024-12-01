defmodule HistorianHysteria do
  defmodule Util do
    defp check_file_exists!(path) do
      unless File.exists?(path) do
        raise "Create a file called '#{path}' containing the input to run this function."
      end

      path
    end

    defp extract_columns_reversed(path) do
      path
      |> File.stream!([], :line)
      |> Enum.reduce({[], []}, fn line, {col1, col2} ->
        [num1, num2] =
          String.split(line, "   ")
          |> Enum.map(&String.trim/1)
          |> Enum.map(&String.to_integer/1)

        {[num1 | col1], [num2 | col2]}
      end)
    end

    def extract_columns_sorted(path) do
      {col1, col2} = extract_columns_reversed(path)
      {Enum.sort(col1), Enum.sort(col2)}
    end

    def extract_columns(path) do
      {col1, col2} = extract_columns_reversed(path)
      {Enum.reverse(col1), Enum.reverse(col2)}
    end

    def check_path_before_exec(path, func) do
      path
      |> check_file_exists!()
      |> func.()
    end
  end

  defmodule Task1 do
    defp lists_diff(list1, list2) do
      list1
      |> Enum.zip(list2)
      |> Enum.map(fn {x, y} -> abs(x - y) end)
    end

    def sum_lists_diff do
      Util.check_path_before_exec("./input", &sum_lists_diff/1)
    end

    def sum_lists_diff(path) do
      {list1, list2} = Util.extract_columns_sorted(path)

      lists_diff(list1, list2)
      |> Enum.sum()
    end
  end

  defmodule Task2 do
    defp lists_sim_scores(list1, list2) do
      list1
      |> Enum.map(fn num1 -> num1 * Enum.count(list2, fn num2 -> num1 == num2 end) end)
    end

    def sum_sim_scores do
      Util.check_path_before_exec("./input", &sum_sim_scores/1)
    end

    def sum_sim_scores(path) do
      {list1, list2} = Util.extract_columns(path)

      lists_sim_scores(list1, list2)
      |> Enum.sum()
    end
  end
end

defmodule RedNosedReports do
  defmodule Util do
    defp check_file_exists!(path) do
      unless File.exists?(path) do
        raise "Create a file called '#{path}' containing the input to run this function."
      end

      path
    end

    def check_path_before_exec(path, func, task2), do: check_file_exists!(path) |> func.(task2)

    def extract_lines(path) do
      lines =
        path
        |> File.stream!([], :line)
        |> Enum.reduce([], fn line, lines ->
          line_list =
            line
            |> String.split(" ")
            |> Enum.map(&String.trim/1)
            |> Enum.map(&String.to_integer/1)

          [line_list | lines]
        end)

      Enum.reverse(lines)
    end
  end

  defmodule Task do
    defp determine_safety(chunked_report, predicate) do
      Enum.all?(chunked_report, fn [num1, num2] -> predicate.(num1, num2) end)
    end

    defp is_differing_by_one_to_three(num1, num2) do
      diff = abs(num1 - num2)
      diff >= 1 and diff <= 3
    end

    defp report_is_safe(report) do
      chunked_report =
        report
        |> Enum.chunk_every(2, 1)
        |> Enum.drop(-1)

      is_increasing_and_correctly_differing =
        determine_safety(chunked_report, fn num1, num2 ->
          num1 < num2 && is_differing_by_one_to_three(num1, num2)
        end)

      is_decreasing_and_correctly_differing =
        determine_safety(chunked_report, fn num1, num2 ->
          num1 > num2 && is_differing_by_one_to_three(num1, num2)
        end)

      is_increasing_and_correctly_differing or is_decreasing_and_correctly_differing
    end

    defp increasing_or_decreasing?(reports, task2) do
      reports
      |> Enum.map(fn report ->
        result = report_is_safe(report)

        cond do
          result ->
            result

          true ->
            if task2 do
              len = length(report) - 1

              Enum.reduce_while(0..len, :ok, fn index, _ ->
                if report_is_safe(List.delete_at(report, index)) do
                  {:halt, true}
                else
                  {:cont, false}
                end
              end)
            else
              result
            end
        end
      end)
    end

    def run do
      "./input" |> Util.check_path_before_exec(&run/2, true)
    end

    def run(path) do
      path |> Util.check_path_before_exec(&run/2, true)
    end

    def run(path, task2) do
      lines = Util.extract_lines(path)
      lines_length = length(lines)

      if lines_length == 0 do
        raise "An empty list was given as input."
      else
        if length(hd(lines)) == 1 do
          true
        else
          increasing_or_decreasing?(lines, task2)
          |> Enum.count(fn x -> x end)
        end
      end
    end
  end
end

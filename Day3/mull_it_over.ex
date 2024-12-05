defmodule MullItOver do
  defmodule Util do
    defp check_file_exists!(path) do
      unless File.exists?(path) do
        raise "Create a file called '#{path}' containing the input to run this function."
      end

      path
    end

    def check_path_before_exec(path, func), do: check_file_exists!(path) |> func.()
  end

  defp parse_mul(mul) do
    case Regex.run(~r/^mul\((\d{1,3}),(\d{1,3})\)$/, mul) do
      [_, num1, num2] -> {String.to_integer(num1), String.to_integer(num2)}
      _ -> {:error, mul}
    end
  end

  defp valid_head?(head), do: Regex.match?(~r/^mul\(\d{1,3}$/, head)

  defp valid_tail?(tail) do
    case tail do
      [] ->
        true

      [""] ->
        true

      [content] ->
        cond do
          Regex.match?(~r/^\d{1,3}$/, content) -> true
          is_end(String.at(content, -1)) -> true
          true -> false
        end

      _ ->
        false
    end
  end

  defp is_end(byte) do
    byte == ")"
  end

  defp validate_candidate(candidate) do
    case candidate do
      candidate
      when candidate in [
             "m",
             "mu",
             "mul",
             "mul(",
             "d",
             "do",
             "do(",
             "don",
             "don'",
             "don't",
             "don't("
           ] ->
        :continue

      "do()" ->
        :keep

      "don't()" ->
        :keep

      _ ->
        if String.length(candidate) > 4 do
          [head | tail] = String.split(candidate, ",")

          cond do
            not valid_head?(head) ->
              :discard

            not valid_tail?(tail) ->
              :discard

            is_end(String.at(candidate, -1)) ->
              :keep

            true ->
              :continue
          end
        else
          :discard
        end
    end
  end

  defp extract_factors(path) do
    path
    |> File.stream!([], 1)
    |> Stream.transform("", fn byte, acc ->
      candidate = acc <> byte

      case validate_candidate(candidate) do
        :continue -> {[], candidate}
        :keep -> {[candidate], ""}
        :discard -> {[], ""}
      end
    end)
    |> Enum.reduce({"do()", []}, fn x, {mode, muls} ->
      if x == "do()" or x == "don't()" do
        {x, muls}
      else
        {mode,
         if mode == "do()" do
           [x | muls]
         else
           muls
         end}
      end
    end)
    |> elem(1)
    |> Enum.map(&parse_mul/1)

    # |> Enum.map(fn x -> x end)
  end

  def run, do: "./input" |> Util.check_path_before_exec(&run/1)

  def run(path) do
    extract_factors(path)
    |> Enum.reduce(0, fn {x, y}, acc -> x * y + acc end)
  end
end

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

  defp extract_factors(path) do
    path
    |> File.stream!([], 1)
    |> Stream.transform("", fn byte, acc ->
      candidate = acc <> byte
      len = String.length(candidate)

      cond do
        len == 1 and byte != "m" ->
          {[], ""}

        len == 2 and byte != "u" ->
          {[], ""}

        len == 3 and byte != "l" ->
          {[], ""}

        len == 4 and byte != "(" ->
          {[], ""}

        len > 4 ->
          [head | tail] = String.split(candidate, ",")

          cond do
            not Regex.match?(~r/^mul\(\d{1,3}$/, head) ->
              {[], ""}

            tail != [] and tail != [""] and
                ((byte != ")" and
                    not Regex.match?(~r/^\d{1,3}$/, hd(tail))) or length(tail) != 1) ->
              {[], ""}

            byte == ")" ->
              {[candidate], ""}

            true ->
              {[], candidate}
          end

        true ->
          {[], candidate}
      end
    end)
    |> Enum.map(&parse_mul/1)
  end

  def run, do: "./input" |> Util.check_path_before_exec(&run/1)

  def run(path) do
    extract_factors(path)
    |> Enum.reduce(0, fn {x, y}, acc -> x * y + acc end)
  end
end

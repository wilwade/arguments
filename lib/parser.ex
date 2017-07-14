defmodule Arguments.Parser do
  @moduledoc """
  Parses arguments into a map for easy pattern matching
  """

  @doc """
  Parse will take a list of incoming arguments and a list of built arguments to generate a map
  """
  @spec parse(String.t, [map]) :: map
  def parse(incoming, arguments) do
    incoming
    |> OptionParser.parse(
      strict: get_switches(arguments),
      aliases: get_aliases(arguments))
    |> flags_to_map()
    |> apply_commands(arguments)
    |> just_flags()
    |> apply_defaults(arguments)
  end

  @spec get_switches([map]) :: map
  defp get_switches(arguments) do
    arguments
    |> Enum.filter(&Map.get(&1, :type))
    |> Enum.map(&({&1.name, &1.type}))
  end

  @spec get_aliases([map]) :: map
  defp get_aliases(arguments) do
    arguments
    |> Enum.filter(&Map.get(&1, :alias))
    |> Enum.map(&({&1.alias, &1.name}))
  end

  @spec get_aliases({term, any}) :: term
  defp just_flags({flags, _}), do: flags

  @spec flags_to_map({[{any, any}], [String.t], any}) :: {map, [String.t]}
  defp flags_to_map({kw, incoming_args, _bad_args}) do
    {Map.new(kw), incoming_args}
  end

  @spec apply_commands({map, []}, any) :: {map, []}
  defp apply_commands({flags, []}, _), do: {flags, []}
  @spec apply_commands({map, [String.t]}, [map]) :: {map, [String.t]}
  defp apply_commands({flags, incoming_args}, arguments) do
    arguments
    |> Enum.reduce({flags, incoming_args}, &apply_command/2)
  end

  @spec apply_command(map, {map, []}) :: {map, list}
  defp apply_command(
    %{argument_type: :command, string_name: str_name, name: cmd_name,
      arguments: args},
    {flags, [str_name | incoming_args]}) do
    arguments = Enum.zip(args, incoming_args)
    used = Enum.count(arguments) + 1

    flags = arguments
    |> Enum.reduce(flags, &add_new_flags/2)
    |> Map.put(cmd_name, true) # Tag command

    {flags, Enum.drop(incoming_args, used)}
  end
  @spec apply_command(any, term) :: term
  defp apply_command(_, acc), do: acc

  @spec apply_defaults(map, [map]) :: map
  defp apply_defaults(flags, arguments) do
    arguments
    |> Enum.reduce(flags, &apply_default/2)
  end

  # Only apply the default if it exists in the list of flags
  @spec apply_defaults(map, map) :: map
  defp apply_default(%{name: name, defaults: defaults}, flags) when is_list(defaults) do
    case Map.get(flags, name) do
      nil -> flags
      _ ->  Enum.reduce(defaults, flags, &add_new_flags/2)
    end
  end
  @spec apply_defaults(map, map) :: map
  defp apply_default(%{name: name, defaults: default_fn}, flags) do
    case Map.get(flags, name) do
      nil -> flags
      value -> Enum.reduce(apply_fn(default_fn, value), flags, &add_new_flags/2)
    end
  end
  @spec apply_defaults(any, term) :: term
  defp apply_default(_, flags), do: flags

  @spec apply_defaults(any, any) :: Enum.t
  defp apply_fn(f, value) do
    {func, _} = Code.eval_quoted(f, [])
    func.(value)
  end

  # Apply flag IF not already flagged
  @spec add_new_flags({atom, any}, map) :: map
  defp add_new_flags({k, v}, flags) do
    Map.put_new(flags, k, v)
  end
end

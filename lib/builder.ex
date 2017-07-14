defmodule Arguments.Builder do
  @moduledoc """
  Helps build the list of arguments
  """

  @doc """
  Builds a map of the argument for handling
  """
  @spec create_arg_map(String.t | atom, Enum.t, atom) :: map
  def create_arg_map(name, block, type) do
    block
    |> create_arg_map_new(name, type)
  end
  @spec create_arg_map(String.t | atom, Enum.t, atom, nil) :: map
  def create_arg_map(name, block, type, nil) do
    create_arg_map(name, block, type)
  end
  @doc """
  Builds a map of the argument for handling with defaults
  """
  @spec create_arg_map(String.t | atom, Enum.t, any) :: map
  def create_arg_map(name, block, type, default_fn) do
    block
    |> create_arg_map_new(name, type)
    |> Map.put(:defaults, default_fn)
  end

  @spec create_arg_map_new(Enum.t, String.t | atom, atom) :: map
  defp create_arg_map_new(block, name, type) do
    m = block
        |> Map.new()
        |> Map.put_new(:name, to_atom(name))
        |> Map.put(:argument_type, type)
        |> command_flag(type)
    # Allow for string matching as well
    string_name = m
                  |> Map.get(:name)
                  |> Atom.to_string()
    Map.put(m, :string_name, string_name)
  end

  @spec command_flag(map, atom) :: map
  defp command_flag(arg, :command) do
    Map.put(arg, :type, :boolean)
  end
  @spec command_flag(term, any) :: term
  defp command_flag(arg, _), do: arg

  @doc """
  Extracts the function or list out of the AST
  """
  @spec get_default_fn(map) :: [{any, any}]
  def get_default_fn(m) when is_map(m) do
    m
    |> Map.get(:defaults)
    |> Map.to_list
  end
  @spec get_default_fn([{any, any}]) :: [{any, any}]
  def get_default_fn(kl) when is_list(kl) do
    Keyword.get(kl, :defaults)
  end
  @spec get_default_fn({:%{}, any, term}) :: term
  def get_default_fn({:%{}, _, kl}) do
    Keyword.get(kl, :defaults)
  end

  @spec to_atom(atom) :: atom
  defp to_atom(a) when is_atom(a), do: a
  @spec to_atom(String.t) :: atom
  defp to_atom(s), do: String.to_atom(s)
end

defmodule Arguments do
    @moduledoc """
    Arguments provides a module with argument parsing through `YourArguments.parse(incoming)`

    `use Arguments`

    There are two styles of arguments allowed
    - `command` - `$ cmd new project`
    - `flag` - `$ cmd --dir /etc`

    These two styles can be mixed, but the flags will always take priority

    ## Full Example:
    ```elixir
    module MyArguments do
      use Arguments

      command "new", do: [
        arguments: [:name, :dir]
      ]

      flag "name", do: [
        type: :string,
        alias: :n,
        defaults: fn (n) -> [
          dir: "./#\{n\}"
        ] end
      ]

      flag "more", do: %{
        type: :boolean,
        alias: :m
      }

      flag "dir", do: [
        type: :string
      ]
    end
    ```

    ```elixir
    iex> MyArguments.parse(["--name", "myname"])
    %{name: "myname", dir: "./myname"}

    iex> MyArguments.parse(["new", "myname", "dirhere"])
    %{new: true, name: "myname", dir: "dirhere"}

    iex> MyArguments.parse(["--more"])
    %{more: true}

    iex> MyArguments.parse(["-m"])
    %{more: true}
    ```
    """

  alias Arguments.{Builder, Parser}

  defmacro __using__(_opts) do
    quote do
      import Arguments
      @arguments []

      @before_compile Arguments
    end
  end

  @doc """
  Defines a flag style argument

  ## Required Options:
  - `type:` (atom) Argument type from `OptionParser.parse/1`
    - `:string` parses the value as a string
    - `:boolean` sets the value to true when given
    - `:count` counts the number of times the switch is given
    - `:integer` parses the value as an integer
    - `:float` parses the value as a float

  ## Optional Common Options:
  - `alias:` (atom) Single dash name, e.g. `:d` -> `-d`
  - `defaults:` (fn(value) | list) If the flag is set, the defaults will be applied
      - The end result must be a keyword list. The function form may NOT use anything
        from outside, but will be passed in the value of the flag.
      - Example:
        - `defaults: fn(name) -> [dir: "./#\{name\}"] end`
        - `$ cmd --name myname`
        - `%{name: "myname", dir: "./myname"}`

  ## Optional Uncommon Options:
  - `name:` (atom) Double dash name, e.g. `:dir` -> `--dir` (defaults to flag [name])
  """
  defmacro flag(name, do: block) do
    default_fn = case Builder.get_default_fn(block) do
      nil -> nil
      f -> Macro.escape(f)
    end
    quote bind_quoted: [name: name, block: block, default_fn: default_fn] do
      # flags need to be after command for defaults to apply
      @arguments @arguments
                 ++ [Builder.create_arg_map(name, block, :flag, default_fn)]
    end
  end

  @doc """
  Defines a command style argument

  A command is an ordered set of flags with a boolean flag for itself

  ## Required Options:
  - `arguments:` (list of atoms) [:arg0, arg1] e.g. [:name, :dir]
    - Example
      - `command "new", do [arguments: [:name, :dir]]`
      - `$ cmd new MyName YourDir`
      - `%{new: true, name: "MyName", dir: "YourDir"}`

  ## Optional Uncommon Options:
  - `name:` (atom) Double dash name, e.g. `:dir` -> `--dir` (defaults to command [name])
  """
  defmacro command(name, do: block) do
    quote bind_quoted: [name: name, block: block] do
      # commands need to be first for defaults to apply
      @arguments [Builder.create_arg_map(name, block, :command) | @arguments]
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def arguments, do: @arguments
      def parse(incoming), do: Parser.parse(incoming, @arguments)
    end
  end

end

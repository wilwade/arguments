# Arguments

Arguments parses command line arguments with a declarative, simple setup

Produces results as a map for super pattern matching argument handling in your app!

`$ cmd new myname --more`
into
`%{new: true, name: "myname", more: true}`

Documentation: [https://hexdocs.pm/arguments/](https://hexdocs.pm/arguments/)

## Installation

Add `arguments` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:arguments, "~> 0.1.0"}]
end
```

## Usage

Arguments provides a module with argument parsing through `YourArguments.parse(incoming)`

`use Arguments`

There are two styles of arguments allowed
- [`command`](https://hexdocs.pm/arguments/Arguments.html#command/2) - `$ cmd new project`
- [`flag`](https://hexdocs.pm/arguments/Arguments.html#flag/2) - `$ cmd --dir /etc`

These two styles can be mixed, but the flags will always take priority

### Full Example:
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

  flag "more_defaults", do: %{
    type: :boolean,
    alias: :m,
    defaults: [
      something: "else"
    ]
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

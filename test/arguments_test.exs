defmodule ArgumentsTest do
  use ExUnit.Case

  defmodule TestSimpleArgs do
    use Arguments

    command "new", do: [
      arguments: [:name, :dir]
    ]

    flag "name", do: [
      type: :string,
      alias: :n
    ]

    flag "dir", do: [
      type: :string
    ]
  end

  test "Simple Args" do
    expected = [
      %{argument_type: :command,
        arguments: [:name, :dir],
        name: :new,
        string_name: "new",
        type: :boolean},
      %{alias: :n,
        argument_type: :flag,
        name: :name,
        string_name: "name",
        type: :string},
      %{argument_type: :flag,
        name: :dir,
        string_name: "dir",
        type: :string}]
    assert expected == TestSimpleArgs.arguments()
  end

  test "Aliases" do
    assert TestSimpleArgs.parse(["--name", "testing"]) == TestSimpleArgs.parse(["-n", "testing"])
  end

  defmodule TestCommandArgs do
    use Arguments

    command "new", do: [
      arguments: [:name, :dir]
    ]

    flag "name", do: [
      type: :string,
      alias: :n,
      defaults: fn (n) -> [
        dir: "./#{n}"
      ] end
    ]

    flag "more", do: %{
      type: :string,
      alias: :m
    }

    flag "dir", do: [
      type: :string,
      defaults: [
        other: true
      ]
    ]
  end

  test "Simple Command Defaults: function and list" do
    expected = %{new: true, name: "YourName", dir: "./YourName", other: true}
    assert expected == TestCommandArgs.parse(["new", "YourName"])
  end

  test "Simple Command" do
    expected = %{new: true, name: "YourName", dir: "YourDir", other: true}
    assert expected == TestCommandArgs.parse(["new", "YourName", "YourDir"])
  end

  test "Commands are also boolean flags" do
    expected = %{new: true}
    assert expected == TestCommandArgs.parse(["--new"])
  end

  test "Flags > Command args" do
    expected = %{new: true, name: "YourName", dir: "YourDir", other: true}
    assert expected == TestCommandArgs.parse(["new", "YourName", "MyDir", "--dir", "YourDir"])
  end

  test "Maps work also!" do
    expected = %{more: "maps"}
    assert expected == TestCommandArgs.parse(["--more", "maps"])
  end

  defmodule TestTypesArgs do
    use Arguments

    flag "verbose", do: %{
      type: :count,
      alias: :v
    }

    flag "double", do: [
      type: :float
    ]

    flag "more", do: [
      type: :boolean
    ]
  end

  test "Type Args" do
    expected = [
      %{alias: :v,
        argument_type: :flag,
        name: :verbose,
        string_name: "verbose",
        type: :count},
      %{argument_type: :flag,
        name: :double,
        string_name: "double",
        type: :float},
      %{argument_type: :flag,
        name: :more,
        string_name: "more",
        type: :boolean}]
    assert expected == TestTypesArgs.arguments()
  end

  test "Verbose Count" do
    assert %{verbose: 1} == TestTypesArgs.parse(["--verbose"])
    assert %{verbose: 2} == TestTypesArgs.parse(["--verbose", "--verbose"])
    assert %{verbose: 2} == TestTypesArgs.parse(["--verbose", "-v"])
    assert %{verbose: 3} == TestTypesArgs.parse(["-v", "-v", "-v"])
  end

  test "Float Flags" do
    assert %{double: 0.42} == TestTypesArgs.parse(["--double", "0.42"])
  end

  test "Strict Flags" do
    assert %{} == TestTypesArgs.parse(["--doit"])
    assert %{} == TestTypesArgs.parse(["--done", "it"])
    assert %{more: true} == TestTypesArgs.parse(["--more", "test"])
  end

  defmodule TestAltNameArgs do
    use Arguments

    flag "something", do: %{
      name: :other,
      type: :boolean
    }
  end

  test "AltName Args" do
    expected = [
      %{argument_type: :flag,
        name: :other,
        string_name: "other",
        type: :boolean}]
    assert expected == TestAltNameArgs.arguments()
  end

end

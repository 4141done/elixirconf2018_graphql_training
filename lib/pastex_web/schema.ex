defmodule PastexWeb.Schema do
  use Absinthe.Schema

  @desc "This winds up in the description field as the RootQueryType"
  query do
    field :health, :string do
      resolve(fn _, _, _ ->
        IO.puts "Executing health"
        {:ok, "up"}
      end)
    end

    field :pastes, list_of(:paste) do
      resolve &list_pastes/3
    end
  end

  # This shows in the UI/docs
  @desc "Blobs of pasted code"
  object :paste do
    field :name, non_null(:string) # You will never get a paste where the name is null
    field :excited_name, :string do
      resolve &get_excited_name/3
    end
    field :description, :string
    @desc "A paste can contain multiple files"
    field :files, non_null(list_of(:file)) do
      resolve &get_files/3
    end
  end

  object :file do
    field :name, :string
    field :body, :string
    # Refer back to the parent
    field :paste, non_null(:paste) do
      resolve &get_paste/3
    end
  end

  @pastes [
    %{
      id: 1,
      name: "What it is, world?",
      description: "I always like to move it move it",
    },
    %{
      id: 2,
      name: "Help!",
      description: "Blarb",
    }
  ]

  def list_pastes(_, _, _) do
    IO.puts "Executing pastes"

    {:ok, @pastes}
  end

  def get_paste(file, _, _) do
    @pastes
    |> Enum.find(fn paste -> file.paste_id == paste.id end)
    |> case do
      nil ->
        {:error, "No paste #{inspect file.paste_id}"}
      found ->
        {:ok, found}
    end
  end

  # Kinda like a graphql "virtual field"
  defp get_excited_name(%{name: paste_name}, _, _) do
    paste_name
    |> String.upcase()
    |>(&{:ok, &1}).()
  end

  @files [
    %{
      paste_id: 2,
      name: "foo.ex",
      body: """
      defmodule Foo do
        def bar, do: Bar.bar()
      end
      """
    },
    %{
      paste_id: 2,
      name: "bar.ex",
      body: """
      defmodule Bar do
        def bar, do: Foo.foo()
      end
      """
    },
    %{
      paste_id: 1,
      body: ~s[IO.puts("How is it, world?")]
    }
  ]

  # First argument to the resolver is the parent thing
  # This function is called once for each parent that is found
  def get_files(%{id: paste_id}, _, _) do
    IO.puts("Executing get files")
    @files
    |> Enum.filter(fn file -> file.paste_id == paste_id end)
    |> (&{:ok, &1}).()
  end

end

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
    field :description, :string
    @desc "A paste can contain multiple files"
    field :files, non_null(list_of(:file))
  end

  object :file do
    field :name, :string
    field :body, :string
    # Refer back to the parent
    field :paste, non_null(:paste)
  end

  @pastes [
    %{
      name: "What it is, world?",
      description: "I always like to move it move it",
      files: [
        %{
          body: ~s[IO.puts("How is it, world?")]
        }
      ]
    },
    %{
      name: "Help!",
      description: "Blarb",
      files: [
        %{
          name: "foo.ex",
          body: """
          defmodule Foo do
            def bar, do: Bar.bar()
          end
          """
        },
        %{
          name: "bar.ex",
          body: """
          defmodule Bar do
            def bar, do: Foo.foo()
          end
          """
        }
      ]
    }
  ]

  def list_pastes(_, _, _) do
    IO.puts "Executing pastes"
    {:ok, @pastes}
  end

end

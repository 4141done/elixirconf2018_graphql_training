defmodule PastexWeb.ContentResolver do
  # Notice that this module is named for the *context*
  # Resolvers can really be put anywhere
  # Resolvers have a lot in common with controllers
  alias Pastex.Content

  def list_pastes(_, args, %{context: context}) do
    query = Content.query_pastes(context[:current_user])
    Absinthe.Relay.Connection.from_query(query, &Pastex.Repo.all/1, args) |> IO.inspect()
  end

  def get_files(paste, _, %{context: %{loader: loader}}) do
    # Since thie references methods on the context,
    # We won't be sidestepping our business logic
    loader
    |> Dataloader.load(:content, {:many, Content.File}, paste_id: paste.id)
    |> Absinthe.Resolution.Helpers.on_load(fn loader ->
      files = Dataloader.get(loader, :content, {:many, Content.File}, paste_id: paste.id)
      {:ok, files}
    end)
  end

  ## Mutations

  def create_paste(_, %{input: input}, %{context: context}) do
    input_with_author = case context do
      %{current_user: %{id: id}} ->
        Map.put(input, :author_id, id)

      _ ->
        input
    end

    case Content.create_paste(input_with_author) do
      {:ok, paste} ->
        {:ok, paste}

      {:error, _} ->
        {:error, "Ain't work"}
    end
  end

  ## Subscriptions

  def format_body(file, arguments, _) do
    IO.inspect(arguments)

    case arguments do
      # We can do this because we defined an enum
      %{style: :formatted} ->
        IO.puts("Formatting code")
        {:ok, "SO FORMATTED #{Code.format_string!(file.body)}"}

      _ ->
        {:ok, file.body}
    end
  end
end

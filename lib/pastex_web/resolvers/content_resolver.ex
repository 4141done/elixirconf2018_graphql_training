defmodule PastexWeb.ContentResolver do
  # Notice that this module is named for the *context*
  # Resolvers can really be put anywhere
  # Resolvers have a lot in common with controllers
  alias Pastex.Content

  def list_pastes(_, args, %{context: context}) do
    limit = min(max(args[:limit] || 25, 0), 25)
    offset = max(args[:offset] || 0, 0)
    pastes = Content.list_pastes(context[:current_user], limit: limit, offset: offset)
    {:ok, pastes}
  end

  def get_files(paste, _, _) do
    files =
      paste
      |> Ecto.assoc(:files)
      |> Pastex.Repo.all()

    {:ok, files}
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

defmodule PastexWeb.ContentResolver do
  # Notice that this module is named for the *context*
  # Resolvers can really be put anywhere
  # Resolvers have a lot in common with controllers
  alias Pastex.Content

  def list_pastes(_, _, _) do
    {:ok, Content.list_pastes()}
  end

  def get_files(paste, _, _) do
    files =
      paste
      |> Ecto.assoc(:files)
      |> Pastex.Repo.all()

    {:ok, files}
  end

  def format_body(file, arguments, _) do
    IO.inspect(arguments)
    case arguments do
      # We can do this because we defined an enum
      %{style: :formatted} ->
        IO.puts "Formatting code"
        {:ok, "SO FORMATTED #{Code.format_string!(file.body)}"}

      _ ->
        {:ok, file.body}
    end
  end
end
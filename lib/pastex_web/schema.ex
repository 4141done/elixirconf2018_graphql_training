defmodule PastexWeb.Schema do
  use Absinthe.Schema
  alias PastexWeb.ContentResolver

  import_types PastexWeb.Schema.ContentTypes

  @desc "This winds up in the description field as the RootQueryType"
  query do
    import_fields :content_queries
  end

  mutation do
    import_fields :content_mutations
  end

  # Subscriptions are stored in an ets table
  subscription do
    field :paste_created, :paste do
      config fn _, _ ->
        {:ok, topic: "*"}
      end

      trigger [:create_paste], topic: fn _paste ->
        "*"
      end
    end

    # Basic updating based on listening for updates
    # on a certain id
    field :paste_updated, :paste do
      arg :id, non_null(:id)

      config fn %{id: id}, _ ->
        {:ok, topid: id}
      end

      trigger :update_paste, topic: fn paste ->
        paste.id
      end
    end
  end
end

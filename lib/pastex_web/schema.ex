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
end

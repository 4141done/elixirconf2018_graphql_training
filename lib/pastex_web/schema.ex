defmodule PastexWeb.Schema do
  use Absinthe.Schema
  alias PastexWeb.ContentResolver

  import_types PastexWeb.Schema.{ContentTypes, IdentityTypes}

  @desc "This winds up in the description field as the RootQueryType"
  query do
    import_fields :content_queries
    import_fields :identity_queries
  end

  mutation do
    import_fields :content_mutations
    import_fields :identity_mutations
  end

  # Subscriptions are stored in an ets table
  subscription do
    field :paste_created, :paste do
      config fn _, _ ->
        {:ok, topic: "*"}
      end

      trigger [:create_paste],
        topic: fn _paste ->
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

      trigger :update_paste,
        topic: fn paste ->
          paste.id
        end
    end
  end


  # doing #use Absinthe.Schema causes this to get defined
  # Could also match on the field via meta
  # if Absinthe.Type.meta(field, :check_auth) do
    # Add middlewhere here
  # end
  # You can also put metadata on the object inside the do block
  def middleware(middleware, _field, %{identifier: :user}) do
    # Now all of our auth checks are run before any field on the :user object.
    # Additions to the authorized?/3
    # function will be automatically checked
    [ApolloTracing.Middleware.Tracing, PastexWeb.Middleware.AuthGet | middleware]
  end

  def middleware(middleware, _field, _object) do
    [ApolloTracing.Middleware.Tracing | middleware]
  end
end

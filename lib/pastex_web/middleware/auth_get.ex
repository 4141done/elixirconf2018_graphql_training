defmodule PastexWeb.Middleware.AuthGet do
  @behaviour Absinthe.Middleware

  alias Pastex.Identity
  # Like a conn in a plug, we want to return resolution
  # This will get run before every resolution
  @impl true
  def call(resolution, _) do
    # source is "parent"
    entity = resolution.source

    # what is the field we are currently on
    key = resolution.definition.schema_node.identifier

    # Any metadata you add to the field will show up on resolution.definition.schema_node
    # Absinthe.Type.meta(schema_node, :auth)

    # Current user as added by our custom plug
    current_user = resolution.context[:current_user]

    if Identity.authorized?(entity, key, current_user) do
      resolution
    else
      Absinthe.Resolution.put_result(resolution, {:error, "unauthorized"})
    end
  end
end

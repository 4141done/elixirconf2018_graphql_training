defmodule PastexWeb.Router do
  use PastexWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug PastexWeb.Context
  end

  scope "/" do
    pipe_through(:api)

    forward("/api", Absinthe.Plug,
      schema: PastexWeb.Schema,
      pipeline: {ApolloTracing.Pipeline, :plug},
      analyze_complexity: true,
      max_complexity: 1_000
    )

    # This is for the GUI playground
    forward(
      "/graphiql",
      Absinthe.Plug.GraphiQL,
      schema: PastexWeb.Schema,
      # In da future this will be the default
      interface: :playground,
      socket: PastexWeb.UserSocket,
      pipeline: {ApolloTracing.Pipeline, :plug},
      analyze_complexity: true,
      max_complexity: 1_000
    )
  end
end

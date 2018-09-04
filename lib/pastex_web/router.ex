defmodule PastexWeb.Router do
  use PastexWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/" do
    pipe_through(:api)

    # This is for the GUI playground
    forward(
      "/graphiql",
      Absinthe.Plug.GraphiQL,
      schema: PastexWeb.Schema,
      # In da future this will be the default
      interface: :playground,
      socket: PastexWeb.UserSocket
    )
  end
end

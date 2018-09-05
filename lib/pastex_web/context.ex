defmodule PastexWeb.Context do
  @behaviour Plug

  alias Pastex.Identity.User

  def init(opts), do: opts

  # Here we build the absinthe context, this will
  # get passed into the third arg in our absinthe resolvers
  def call(conn, _opts) do
    context = build_context(conn)
    # Don't put the conn into the context. Specific pieces of information are ok
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    IO.inspect Plug.Conn.get_req_header(conn, "authorization"), label: :auth_header
    # Cowboy downcases all headers
    with ["Bearer "<> token] <- Plug.Conn.get_req_header(conn, "authorization"),
      {:ok, user_id} <- PastexWeb.Auth.verify(token),
      %User{} = user <- Pastex.Identity.get_user(user_id) do
        %{current_user: user}
    else
      _ ->
        %{}
    end
  end
end

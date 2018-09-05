defmodule PastexWeb.Schema.IdentityTypes do
  use Absinthe.Schema.Notation

  alias Pastex.Identity

  object :identity_mutations do
    field :create_session, :session do
      arg :email, non_null(:string)
      arg :password, non_null(:string)

      resolve &create_session/3
    end
  end

  object :session do
    field :user, non_null(:user)
    field :token, non_null(:string)
  end

  object :user do
    field :name, non_null(:string)
    field :email, non_null(:string)
  end

  # It's not a recommendation to do the resolver inline like this
  # just doing it this way for expediency
  defp create_session(_, %{email: email, password: password}, _) do
    case Identity.authenticate(email, password) do
      {:ok, user} ->
        session = %{
          user: user,
          token: PastexWeb.Auth.sign(user.id)
        }

        {:ok, session}

      error ->
        error
    end
  end
end

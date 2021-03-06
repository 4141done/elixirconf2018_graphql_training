defmodule PastexWeb.Schema.IdentityTypes do
  use Absinthe.Schema.Notation

  alias Pastex.Identity

  object :identity_queries do
    field :me, :user do
      resolve fn _, _, %{context: context} ->
        {:ok, context[:current_user]}
      end
    end
  end

  object :identity_mutations do
    field :create_session, :session do
      arg :email, non_null(:string)
      arg :password, non_null(:string)

      # Same as middleware Absinthe.Resolution, &create_session/3
      resolve &create_session/3
    end
  end

  object :session do
    field :user, non_null(:user)
    field :token, non_null(:string)
  end

  object :user do
    field :name, :string
    field :email, :string
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

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

      resolve &create_session/3
    end
  end

  object :session do
    field :user, non_null(:user)
    field :token, non_null(:string)
  end

  object :user do
    field :name, :string
    # If this is null, then the null value will get pushed up to the first nullable
    # parent object
    field :email, non_null(:string) do
      # This is an example of bad approach
      resolve fn %{id: id} = user, _, %{context: context} ->
        IO.inspect id
        IO.inspect context[:current_user]
        case context do
          %{current_user: %{id: ^id}} ->
            IO.puts "doing user email"
            {:ok, user.email}
          _ ->
            IO.puts "should have returned error"
            {:error, %{message: "unauthorized", code: 403}}
        end
      end
    end
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

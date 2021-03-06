defmodule Pastex.Identity do
  @moduledoc """
  The Identity context.
  """

  import Ecto.Query, warn: false
  alias Pastex.Repo

  alias Pastex.Identity.User
  alias Comeonin.Ecto.Password

  # the pattern match enforces binding of the same name
  def authorized?(%User{id: id}, :email, %User{id: id}) do
    true
  end

  def authorized?(%User{}, :email, _), do: false

  def authorized?(_, _,  _), do: true

  def authenticate(email, password) do
    user = Repo.get_by(User, email: email)

    if user && Password.valid?(password, user.password) do
      {:ok, user}
    else
      {:error, "unauthorized"}
    end
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user(id) do
    Process.sleep(20)
    Repo.get(User, id)
  end

  def get_users(_, user_ids) do
    Process.sleep(20)
    User
    |> where([u], u.id in ^Enum.uniq(user_ids))
    |> Repo.all()
    |> Map.new(fn user -> {user.id, user} end)
    |> IO.inspect(label: :get_users_result)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end

defmodule PastexWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  alias PastexWeb.ContentResolver
  # Query, Mutation, Subscription must be in schema.ex
  # This shows in the UI/docs
  @desc "Blobs of pasted code"
  object :paste do
    # It is conventional to treat ids as opaque
    field :id, non_null(:id)
    # You will never get a paste where the name is null
    field :name, non_null(:string)
    field :description, :string

    field :author, :user do
      resolve fn
        %{author_id: nil}, _, _ ->
          {:ok, nil}

        %{author_id: author_id}, _, _ ->
          {:ok, Pastex.Identity.get_user(author_id)}
      end
    end

    @desc "A paste can contain multiple files"
    field :files, non_null(list_of(:file)) do
      resolve &ContentResolver.get_files/3
    end
  end

  object :file do
    field :id, non_null(:id)

    field :name, :string do
      resolve fn file, _, _ ->
        {:ok, Map.get(file, :name) || "Untitled"}
      end
    end

    field :body, :string do
      arg :style, :body_style, default_value: :original
      resolve &ContentResolver.format_body/3
    end

    # Refer back to the parent
    field :paste, non_null(:paste) do
      resolve &ContentResolver.get_paste/3
    end
  end

  # This is a "dummy object" that we use to hold fields
  # and import using import_fields in schema.ex
  object :content_queries do
    field :health, :string do
      resolve(fn _, _, _ ->
        IO.puts("Executing health")
        {:ok, "up"}
      end)
    end

    field :pastes, list_of(:paste) do
      resolve &ContentResolver.list_pastes/3
    end
  end

  object :content_mutations do
    field :create_paste, :paste do
      arg :input, non_null(:create_paste_input)
      resolve &ContentResolver.create_paste/3
    end
  end

  input_object :create_paste_input do
    field :name, non_null(:string)
    field :description, :string
    field :files, non_null(list_of(non_null(:file_input)))
  end

  input_object :file_input do
    field :name, :string
    field :body, :string
  end

  # Allows deprecation of options
  # Enums are good. Also allows you to reference the
  # arguments as atoms
  enum :body_style do
    value :formatted
    value :original
  end
end

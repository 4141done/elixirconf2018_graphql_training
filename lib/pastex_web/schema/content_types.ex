defmodule PastexWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  alias PastexWeb.ContentResolver
  # Query, Mutation, Subscription must be in schema.ex
  # This shows in the UI/docs
  @desc "Blobs of pasted code"
  object :paste do
    field :name, non_null(:string) # You will never get a paste where the name is null
    field :description, :string
    @desc "A paste can contain multiple files"
    field :files, non_null(list_of(:file)) do
      resolve &ContentResolver.get_files/3
    end
  end

  object :file do
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

  # Allows deprecation of options
  # Enums are good. Also allows you to reference the
  # arguments as atoms
  enum :body_style do
    value :formatted
    value :original
  end
end

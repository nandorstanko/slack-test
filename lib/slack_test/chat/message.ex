defmodule SlackTest.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :body, :string
    field :subject, :string
    field :slack_channel, :string
    field :slack_timestamp, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:subject, :body, :slack_channel, :slack_timestamp])
    |> validate_required([:subject])
  end
end

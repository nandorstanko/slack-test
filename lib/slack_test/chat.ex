defmodule SlackTest.Chat do
  @moduledoc """
  The Chat context.
  """

  import Ecto.Query, warn: false
  alias SlackTest.Repo

  alias SlackTest.Chat.Message

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:message_created, "messages")
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
    |> broadcast(:message_updated, "messages")
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
    |> broadcast(:message_deleted, "messages")
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  def post_message_to_slack(%Message{} = message) do
    case Slack.Web.Chat.post_message(Application.get_env(:slack, :channel), "*#{message.subject}*\n#{message.body}") do
      %{"ts" => ts, "channel" => channel} ->
        update_message(message, %{"slack_channel" => channel, "slack_timestamp" => ts})
      %{"error" => error} -> {:error, error}
    end
  end

  def delete_message_from_slack(%Message{} = message) do
    case Slack.Web.Chat.delete(message.slack_channel, message.slack_timestamp) do
      %{"error" => error} -> {:error, error}
      _ -> {:ok, message}
    end
  end

  def subscribe(schema) do
    Phoenix.PubSub.subscribe(SlackTest.PubSub, schema)
  end

  defp broadcast({:error, _reason} = error, _event, _schema), do: error

  defp broadcast({:ok, entity}, event, schema) do
    Phoenix.PubSub.broadcast(SlackTest.PubSub, schema, {event, entity})
    {:ok, entity}
  end
end

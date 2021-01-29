defmodule SlackTestWeb.MessageLive.Index do
  use SlackTestWeb, :live_view

  import Ecto.Query, only: [order_by: 2]

  alias SlackTest.Chat
  alias SlackTest.Chat.Message
  alias SlackTest.Repo

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Chat.subscribe("messages")

    socket =
      socket
      |> assign(update_action: "replace")

    {:ok, assign(socket, list_messages(socket)), temporary_assigns: [messages: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Message")
    |> assign(:message, %Message{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Message")
    |> assign(:message, Chat.get_message!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Messages")
    |> assign(:message, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    message = Chat.get_message!(id)
    {:ok, _} = Chat.delete_message(message)

    Chat.delete_message_from_slack(message)

    {:noreply, socket}
  end

  def handle_event("load_more", _, socket) do
    socket = assign(socket, update_action: "append")

    %{
      messages: older_messages,
      metadata: metadata
    } = list_messages(socket)

    socket = assign(socket, metadata: metadata)

    {:noreply, update(socket, :messages, fn messages -> messages ++ older_messages end)}
  end

  @impl true
  def handle_info({_, message}, socket) do
    {:noreply, assign(socket, update_action: "prepend") |> update(:messages, fn messages -> [message | messages] end)}
  end

  defp list_messages(socket) do
    %{
      entries: entries,
      metadata: metadata
    } =
      Message
      |> order_by(desc: :id)
      |> paginate_messages(socket)

    %{
      messages: entries,
      metadata: metadata
    }
  end

  defp paginate_messages(
         query,
         %{
           assigns: %{
             update_action: update_action,
             metadata: %{after: cursor_after, first: first} = metadata
           }
         }
       ) do
    case update_action do
      "append" ->
        query
        |> Repo.cursor_paginate(after: cursor_after, cursor_fields: [{:id, :desc}])
        |> put_first_cursor(first)

      "prepend" ->
        query
        |> Repo.cursor_paginate(before: first, cursor_fields: [{:id, :desc}], limit: 100)
        |> Map.put(:metadata, metadata)
        |> put_first_cursor

      _ ->
        paginate_messages(query, %{})
    end
  end

  defp paginate_messages(query, _) do
    query
    |> Repo.cursor_paginate(cursor_fields: [{:id, :desc}])
    |> put_first_cursor
  end

  defp put_first_cursor(%{entries: entries} = result) when entries == [], do: result

  defp put_first_cursor(%{entries: entries, metadata: metadata}) do
    %{
      entries: entries,
      metadata: Map.put(metadata, :first, hd(entries) |> Paginator.cursor_for_record([:id]))
    }
  end

  defp put_first_cursor(%{entries: entries, metadata: metadata}, value) do
    %{
      entries: entries,
      metadata: Map.put(metadata, :first, value)
    }
  end
end

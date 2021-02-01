defmodule SlackTest.ChatTest do
  use SlackTest.DataCase
  use ExUnit.Case, async: true

  alias SlackTest.Chat

  describe "messages" do
    alias SlackTest.Chat.Message

    @valid_attrs %{body: "some body", subject: "some subject"}
    @update_attrs %{body: "some updated body", subject: "some updated subject"}
    @invalid_attrs %{body: nil, subject: nil}

    setup do
      bypass = Bypass.open(port: 8000)
      {:ok, bypass: bypass}
    end

    def message_fixture(attrs \\ %{}) do
      {:ok, message} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Chat.create_message()

      message
    end

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Chat.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Chat.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      assert {:ok, %Message{} = message} = Chat.create_message(@valid_attrs)
      assert message.body == "some body"
      assert message.subject == "some subject"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      assert {:ok, %Message{} = message} = Chat.update_message(message, @update_attrs)
      assert message.body == "some updated body"
      assert message.subject == "some updated subject"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_message(message, @invalid_attrs)
      assert message == Chat.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Chat.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Chat.change_message(message)
    end

    test "post_message_to_slack/1 posts message to Slack", %{bypass: bypass} do
      message = message_fixture()

      Bypass.expect_once(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, ~s<{"ok": true, "ts": "", "channel": ""}>)
      end)

      assert {:ok, message} == Chat.post_message_to_slack(message)
    end

    test "delete_message_from_slack/1 deletes message from Slack", %{bypass: bypass} do
      message = message_fixture()

      Bypass.expect_once(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, ~s<{"ok": true, "ts": "", "channel": ""}>)
      end)

      assert {:ok, message} == Chat.delete_message_from_slack(message)
    end
  end
end

defmodule SlackTestWeb.MessageLiveTest do
  use SlackTestWeb.ConnCase

  import Phoenix.LiveViewTest

  alias SlackTest.Chat

  @create_attrs %{body: "some body", subject: "some subject"}
  @update_attrs %{body: "some updated body", subject: "some updated subject"}
  @invalid_attrs %{body: nil, subject: nil}

  defp fixture(:message) do
    {:ok, message} = Chat.create_message(@create_attrs)
    message
  end

  defp create_message(_) do
    message = fixture(:message)
    %{message: message}
  end

  describe "Index" do
    setup [:create_message]

    test "lists all messages", %{conn: conn, message: message} do
      {:ok, _index_live, html} = live(conn, Routes.message_index_path(conn, :index))

      assert html =~ "Listing Messages"
      assert html =~ message.body
    end

    test "saves new message", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.message_index_path(conn, :index))

      assert index_live |> element("a", "Add New") |> render_click() =~
               "Add New"

      assert_patch(index_live, Routes.message_index_path(conn, :new))

      assert index_live
             |> form("#message-form", message: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#message-form", message: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.message_index_path(conn, :index))

      assert html =~ "Message created successfully"
      assert html =~ "some body"
    end

    test "updates message in listing", %{conn: conn, message: message} do
      {:ok, index_live, _html} = live(conn, Routes.message_index_path(conn, :index))

      assert index_live |> element("#message-#{message.id} a", "Edit") |> render_click() =~
               "Edit Message"

      assert_patch(index_live, Routes.message_index_path(conn, :edit, message))

      assert index_live
             |> form("#message-form", message: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#message-form", message: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.message_index_path(conn, :index))

      assert html =~ "Message updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes message in listing", %{conn: conn, message: message} do
      {:ok, index_live, _html} = live(conn, Routes.message_index_path(conn, :index))

      assert index_live |> element("#message-#{message.id} a", "Delete") |> render_click()
      assert has_element?(index_live, "#message-#{message.id}.d-none")
    end
  end
end

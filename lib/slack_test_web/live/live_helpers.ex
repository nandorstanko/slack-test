defmodule SlackTestWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `SlackTestWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, SlackTestWeb.MessageLive.FormComponent,
        id: @message.id || :new,
        action: @live_action,
        message: @message,
        return_to: Routes.message_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, SlackTestWeb.ModalComponent, modal_opts)
  end
end

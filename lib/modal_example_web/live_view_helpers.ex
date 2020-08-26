defmodule ModalExampleWeb.LiveViewHelpers do
  @moduledoc false
  import Phoenix.LiveView

  @spec put_flash_notice(Phoenix.LiveView.Socket.t(), atom(), String.t()) :: map
  def put_flash_notice(socket, kind, message) do
    push_event(socket, "show-flash-notice", %{kind: kind, message: message})
  end
end

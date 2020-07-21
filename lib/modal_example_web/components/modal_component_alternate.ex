defmodule ModalExampleWeb.ModalComponentAlternate do
  @moduledoc """
  This is a general modal component with a title, body text, and either
  one or two buttons. Many aspects of the modal can be customized, including
  colors, button labels, and title and body text. Application wide defaults
  are specified for the colors and button texts.

  A required action string and optional parameter are provided for each
  button when the modal is initialized. These will be returned to the caller
  when the corresponding button is clicked.

  The caller must have message handlers defined for each button that takes
  the given action and parameter for each button. For example:

    def handle_info(
        {ModalComponent, :button_pressed,
         %{action: "remove-item-confirmed", param: display_order_of_item}},
        socket
      )

  Also, the caller should have a 'modal_closed' event handler that will be called when the
  modal is closed with a click-away or escape key press.

    def handle_info(
        {ModalComponent, :modal_closed, %{id: "confirm-heading-removal"}},
        socket
      ) do

  This is a stateful component, so you MUST specify an id when calling
  live_component.

  The display of the modal is determined by the required show assign.

  The component can be called like:

  <%= live_component(@socket, ModalComponent,
      id: "confirm-delete-member",
      show: @live_action == :delete_member,
      title: "Delete Member",
      body: "Are you sure you want to delete team member?",
      right_button: "Delete",
      right_button_action: "delete-member",
      left_button: "Cancel",
      left_button_action: "cancel-delete-member")
  %>
  """

  use ModalExampleWeb, :live_component
  import Process, only: [send_after: 3]

  @defaults %{
    show: false,
    enter_duration: 300,
    leave_duration: 200,
    background_color: "bg-gray-500",
    background_opacity: "opacity-75",
    title_color: "text-gray-900",
    body_color: "text-gray-500",
    left_button: nil,
    left_button_action: nil,
    left_button_param: nil,
    right_button: nil,
    right_button_color: "red",
    right_button_action: nil,
    right_button_param: nil
  }

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, @defaults)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("modal-closed", _params, socket) do
    # Handle event fired from Modal hook leave_duration-milliseconds
    # afer open transitions to false.
    send(self(), {__MODULE__, :modal_closed, %{id: socket.assigns.id}})

    {:noreply, assign(socket, show: false)}
  end

  # Fired when user clicks right button on modal
  def handle_event(
        "right-button-click",
        _params,
        %{
          assigns: %{
            right_button_action: right_button_action,
            right_button_param: right_button_param,
            leave_duration: leave_duration
          }
        } = socket
      ) do
    send(
      self(),
      {__MODULE__, :button_pressed, %{action: right_button_action, param: right_button_param}}
    )

    send_after(self(), {__MODULE__, :modal_closed, %{id: socket.assigns.id}}, leave_duration)

    {:noreply, socket}
  end

  def handle_event(
        "left-button-click",
        _params,
        %{
          assigns: %{
            left_button_action: left_button_action,
            left_button_param: left_button_param,
            leave_duration: leave_duration
          }
        } = socket
      ) do
    send(
      self(),
      {__MODULE__, :button_pressed, %{action: left_button_action, param: left_button_param}}
    )

    send_after(self(), {__MODULE__, :modal_closed, %{id: socket.assigns.id}}, leave_duration)

    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~L"""
    <%= if @show do %>
    <div id="<%= @id %>"
         phx-hook="Modal"
         x-data="{ open: false }"
         x-init="() => {
           setTimeout(() => open = true, 0)
           $nextTick(() => $refs.modalRightButton.focus())
           $watch('open', isOpen => {
             if (!isOpen) {
               modalHook.modalClosing(<%= @leave_duration %>)
             }
           })
         }"
         @keydown.escape.window="if (connected) open = false"
         x-show="open"
         x-cloak>
      <div class="z-50 fixed bottom-0 inset-x-0 px-4 pb-4 sm:inset-0 sm:flex sm:items-center sm:justify-center">
        <!-- BACKDROP -->
        <div x-show="open"
             x-cloak
             x-transition:enter="ease-out duration-<%= @enter_duration %>"
             x-transition:enter-start="opacity-0"
             x-transition:enter-end="opacity-100"
             x-transition:leave="ease-in duration-<%= @leave_duration %>"
             x-transition:leave-start="opacity-100"
             x-transition:leave-end="opacity-0"
             class="fixed inset-0 transition-opacity">
          <div class="absolute inset-0 <%= @background_color %> <%= @background_opacity %>"></div>
        </div>
        <div x-show="open"
             x-cloak
             @click.away="if (connected) open = false"
             x-transition:enter="ease-out duration-<%= @enter_duration %>"
             x-transition:enter-start="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
             x-transition:enter-end="opacity-100 translate-y-0 sm:scale-100"
             x-transition:leave="ease-in duration-<%= @leave_duration %>"
             x-transition:leave-start="opacity-100 translate-y-0 sm:scale-100"
             x-transition:leave-end="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
             class="bg-white rounded-lg overflow-hidden shadow-xl transform transition-all sm:max-w-lg sm:w-full"
             role="dialog"
             aria-modal="true"
             aria-labelledby="modal-headline"
             aria-describedby="modal-description">
          <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
            <div class="sm:flex sm:items-start">
              <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10">
                <svg class="h-6 w-6 text-red-600"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor">
                  <path stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
              </div>
              <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                <h3 class="text-lg leading-6 font-medium <%= @title_color %>"
                    id="modal-headline">
                  <%= @title %>
                </h3>
                <div class="mt-2">
                  <p class="text-sm leading-5 <%= @body_color %>"
                     id="modal-description">
                    <%= @body %>
                  </p>
                </div>
              </div>
            </div>
          </div>
          <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
            <span class="flex w-full rounded-md shadow-sm sm:ml-3 sm:w-auto">
              <button type="button"
                      phx-click="right-button-click"
                      phx-target="#<%= @id %>"
                      class="inline-flex justify-center w-full rounded-md border border-transparent px-4 py-2 bg-<%= @right_button_color %>-600 text-base leading-6 font-medium text-white shadow-sm hover:bg-<%= @right_button_color %>-500 focus:outline-none focus:border-<%= @right_button_color %>-700 focus:shadow-outline-<%= @right_button_color %> transition ease-in-out duration-150 sm:text-sm sm:leading-5"
                      x-ref="modalRightButton"
                      @click="if (connected) open = false">
                <%= @right_button %>
              </button>
            </span>
            <%= if @left_button != nil do %>
            <span class="mt-3 flex w-full rounded-md shadow-sm sm:mt-0 sm:w-auto">
              <button type="button"
                      phx-click="left-button-click"
                      phx-target="#<%= @id %>"
                      class="inline-flex justify-center w-full rounded-md border border-gray-300 px-4 py-2 bg-white text-base leading-6 font-medium text-gray-700 shadow-sm hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue transition ease-in-out duration-150 sm:text-sm sm:leading-5"
                      @click="if (connected) open = false">
                <%= @left_button %>
              </button>
            </span>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    <template phx-hook="ConnectionStatus"></template>
    <% else %>
      <div class="hidden"></div>
    <% end %>
    """
  end
end

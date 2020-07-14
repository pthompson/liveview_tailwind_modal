defmodule ModalExampleWeb.TeamLive do
  @moduledoc false
  use ModalExampleWeb, :live_view
  alias ModalExampleWeb.ModalComponent

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       team_members: members(),
       reconnected: get_connect_params(socket)["_mounts"] > 0,
       base_page_loaded: false,
       member_to_delete: nil
     )}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @spec apply_action(Socket.t(), atom(), map()) :: Socket.t()
  def apply_action(socket, :index, _params) do
    assign(socket, member_to_delete: nil, base_page_loaded: true)
  end

  def apply_action(socket, :delete_member, %{"id" => user_id}) do
    member =
      get_member(
        socket.assigns.team_members,
        String.to_integer(user_id)
      )

    if member && okay_to_show_modal?(socket) do
      assign(socket, member_to_delete: member)
    else
      push_patch_index(socket)
    end
  end

  @impl Phoenix.LiveView
  def handle_event("delete-member", %{"user-id" => user_id}, socket) do
    {:noreply, push_patch_delete_member_modal(socket, user_id)}
  end

  # Handle message to self() from Remove Member confirmation modal ok button
  def handle_info(
        {ModalComponent, :button_pressed, %{action: "delete-member"}},
        %{assigns: %{member_to_delete: member_to_delete, team_members: team_members}} = socket
      ) do
    team_members = delete_member(team_members, member_to_delete.user_id)

    {:noreply,
     socket
     |> assign(team_members: team_members)}
  end

  # Handle message to self() from Remove User confirmation modal cancel button
  def handle_info(
        {ModalComponent, :button_pressed, %{action: "cancel-delete-member", param: _}},
        socket
      ) do
    {:noreply, socket}
  end

  # Modal closed message
  @impl Phoenix.LiveView
  def handle_info(
        {ModalComponent, :modal_closed, %{id: "confirm-delete-member"}},
        socket
      ) do
    {:noreply, push_patch_index(socket)}
  end

  defp okay_to_show_modal?(socket) do
    %{assigns: %{base_page_loaded: base_page_loaded, reconnected: reconnected}} = socket

    !connected?(socket) || base_page_loaded || reconnected
  end

  defp push_patch_index(socket) do
    push_patch(
      socket,
      to: Routes.team_path(socket, :index),
      replace: true
    )
  end

  defp push_patch_delete_member_modal(socket, user_id) do
    push_patch(
      socket,
      to: Routes.team_path(socket, :delete_member, user_id),
      replace: true
    )
  end

  defp get_member(team_members, user_id) do
    Enum.find(team_members, fn member -> member.user_id == user_id end)
  end

  defp delete_member(team_members, user_id) do
    Enum.reject(team_members, fn member -> member.user_id == user_id end)
  end

  defp members do
    [
      %{
        user_id: 1,
        avatar:
          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80",
        name: "Julius Rivers",
        email: "juliusrivers@example.com",
        position: "Director",
        department: "Human Resources",
        status: "Active",
        role: "Owner"
      },
      %{
        user_id: 2,
        avatar:
          "https://images.unsplash.com/photo-1505503693641-1926193e8d57?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80",
        name: "Frank Wilder",
        email: "frankwilder@example.com",
        position: "Director",
        department: "Human Resources",
        status: "Active",
        role: "Owner"
      },
      %{
        user_id: 3,
        avatar:
          "https://images.unsplash.com/photo-1463453091185-61582044d556?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80",
        name: "Gavin Mcdougall",
        email: "gavinmcdougall@example.com",
        position: "Director",
        department: "Human Resources",
        status: "Active",
        role: "Owner"
      },
      %{
        user_id: 4,
        avatar:
          "https://images.unsplash.com/photo-1532910404247-7ee9488d7292?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80",
        name: "Addie Warner",
        email: "addiewarner@example.com",
        position: "Director",
        department: "Human Resources",
        status: "Inactive",
        role: "Owner"
      },
      %{
        user_id: 5,
        avatar:
          "https://images.unsplash.com/photo-1569779213435-ba3167dde7cc?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=256&q=80",
        name: "Juan Alvarez",
        email: "juanalvarez@example.com",
        position: "Director",
        department: "Human Resources",
        status: "Inactive",
        role: "Owner"
      },
      %{
        user_id: 6,
        avatar:
          "https://images.unsplash.com/photo-1589654312430-20441681ac7e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=256&h=256&q=80",
        name: "Sienna Swanson",
        email: "siennaswanson@example.com",
        position: "Director",
        department: "Human Resources",
        status: "Active",
        role: "Owner"
      }
    ]
  end
end

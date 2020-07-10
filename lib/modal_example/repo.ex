defmodule ModalExample.Repo do
  use Ecto.Repo,
    otp_app: :modal_example,
    adapter: Ecto.Adapters.Postgres
end

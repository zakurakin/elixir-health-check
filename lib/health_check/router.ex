defmodule HealthCheck.Router do
  @moduledoc false
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    conn
    |> assign(:otp_app, opts[:otp_app])
    |> super(opts)
  end

  get "/liveness" do
    send_resp(conn, 200, "")
  end

  get "/readiness" do
    otp_app = conn.assigns[:otp_app] || :elixir_health_check
    checks = Application.get_env(otp_app, :health_check_config, [])

    case HealthCheck.check(checks) do
      :ok ->
        send_resp(conn, 200, "")

      {:error, failed_deps} ->
        send_resp(
          conn,
          503,
          Jason.encode!(%{status: "Service Unavailable", failed_dependencies: failed_deps})
        )
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end

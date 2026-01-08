defmodule HealthCheck.Router do
  @moduledoc false
  import Plug.Conn

  defmodule Handler do
    @moduledoc false
    use Plug.Router

    plug(:match)
    plug(:dispatch)

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

  def init(opts), do: opts

  def call(conn, opts) do
    case conn.path_info do
      [path] when path in ["liveness", "readiness"] ->
        dispatch(conn, path, opts)

      ["health", path] when path in ["liveness", "readiness"] ->
        dispatch(conn, path, opts)

      _ ->
        conn
    end
  end

  defp dispatch(conn, path, opts) do
    opts = Enum.into(opts, %{})

    %{conn | path_info: [path]}
    |> assign(:otp_app, opts[:otp_app])
    |> Handler.call(opts)
    |> halt()
  end
end

defmodule HealthCheck.Server do
  @moduledoc """
  Provides a convenient way to start a Bandit server for health checks.
  """

  def child_spec(opts) do
    port = opts[:port] || 4000
    otp_app = opts[:otp_app]

    %{
      id: {Bandit, HealthCheck.Router, port},
      start:
        {Bandit, :start_link,
         [[scheme: :http, plug: {HealthCheck.Router, otp_app: otp_app}, port: port]]},
      type: :worker
    }
  end
end

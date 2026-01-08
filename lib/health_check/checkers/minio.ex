defmodule HealthCheck.Checkers.Minio do
  @moduledoc false
  require Logger

  def check(config \\ []) do
    endpoint = config[:endpoint] || System.get_env("MINIO_ENDPOINT")

    if is_binary(endpoint) and endpoint != "" do
      perform_check(endpoint, config)
    else
      :ok
    end
  end

  defp perform_check(endpoint, config) do
    timeout = config[:timeout] || 5000

    try do
      case HTTPoison.get(endpoint, [], recv_timeout: timeout) do
        {:ok, %HTTPoison.Response{status_code: code}} when code < 500 ->
          :ok

        {:ok, %HTTPoison.Response{status_code: code}} ->
          Logger.error("Minio health check failed for #{endpoint}: status code #{code}")
          {:error, :minio_error}

        {:error, reason} ->
          Logger.error("Minio health check failed for #{endpoint}: #{inspect(reason)}")
          {:error, :minio_error}
      end
    rescue
      e ->
        Logger.error("Minio health check failed for #{endpoint}: #{inspect(e)}")
        {:error, :minio_exception}
    end
  end
end

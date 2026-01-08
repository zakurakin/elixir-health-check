defmodule HealthCheck.Checkers.Minio do
  @moduledoc false
  require Logger

  def check(config \\ []) do
    if Code.ensure_loaded?(ExAws.S3) do
      bucket = config[:bucket] || System.get_env("MINIO_HEALTH_CHECK_BUCKET") || "health-check"

      try do
        case ExAws.S3.list_objects(bucket) |> ExAws.request() do
          {:ok, _} ->
            :ok

          {:error, {:http_error, 404, _}} ->
            # Bucket not found might be acceptable if we just want to check connectivity
            # but let's try to list buckets instead if no bucket is provided
            check_connectivity()

          {:error, reason} ->
            Logger.error("Minio health check failed for bucket #{bucket}: #{inspect(reason)}")
            {:error, :minio_error}
        end
      rescue
        e ->
          Logger.error("Minio health check failed: #{inspect(e)}")
          {:error, :minio_exception}
      end
    else
      :ok
    end
  end

  defp check_connectivity do
    case ExAws.S3.list_buckets() |> ExAws.request() do
      {:ok, _} -> :ok
      {:error, reason} ->
        Logger.error("Minio connectivity check failed: #{inspect(reason)}")
        {:error, :minio_connectivity_error}
    end
  end
end

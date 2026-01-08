defmodule HealthCheck.Checkers.Minio do
  @moduledoc false
  require Logger

  def check(config \\ []) do
    if minio_active?() do
      perform_check(config)
    else
      :ok
    end
  end

  defp minio_active? do
    Code.ensure_loaded?(ExAws.S3) and
      Enum.any?(Application.started_applications(), fn {app, _, _} -> app == :ex_aws end) and
      has_aws_keys?()
  end

  defp perform_check(config) do
    bucket = config[:bucket] || System.get_env("MINIO_HEALTH_CHECK_BUCKET") || "health-check"

    try do
      case bucket |> ExAws.S3.list_objects() |> ExAws.request() do
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
    catch
      kind, reason ->
        Logger.error("Minio health check failed: #{inspect({kind, reason})}")
        {:error, :minio_exception}
    end
  end

  defp check_connectivity do
    case ExAws.request(ExAws.S3.list_buckets()) do
      {:ok, _} ->
        :ok

      {:error, reason} ->
        Logger.error("Minio connectivity check failed: #{inspect(reason)}")
        {:error, :minio_connectivity_error}
    end
  end

  defp has_aws_keys? do
    System.get_env("AWS_ACCESS_KEY_ID") != nil or
      Application.get_env(:ex_aws, :access_key_id) != nil
  end
end

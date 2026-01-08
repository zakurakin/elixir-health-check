defmodule HealthCheck.Checkers.Kafka do
  @moduledoc false
  require Logger

  def check(app_name \\ :kaffe) do
    if Code.ensure_loaded?(Kaffe.Producer) and
         Enum.any?(Application.started_applications(), fn {app, _, _} -> app == app_name end) do
      try do
        endpoints = Application.get_env(:kaffe, :endpoints)

        if is_list(endpoints) and not Enum.empty?(endpoints) do
          case :brod.get_metadata(endpoints, :all) do
            {:ok, metadata} ->
              topics = elem(metadata, 4)

              if Enum.empty?(topics) do
                Logger.warning("Kafka health check: no topics found")
              end

              :ok

            {:error, reason} ->
              Logger.error("Kafka health check failed: #{inspect(reason)}")
              {:error, :kafka_metadata_error}
          end
        else
          Logger.warning("Kafka health check: no endpoints configured")
          :ok
        end
      rescue
        e ->
          Logger.error("Kafka health check failed: #{inspect(e)}")
          {:error, :kafka_exception}
      end
    else
      :ok
    end
  end
end

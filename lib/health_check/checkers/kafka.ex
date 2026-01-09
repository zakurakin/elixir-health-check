defmodule HealthCheck.Checkers.Kafka do
  @moduledoc false
  require Logger

  def check(config \\ []) do
    if Code.ensure_loaded?(Kaffe.Producer) and
         Enum.any?(Application.started_applications(), fn {app, _, _} -> app == :kaffe end) do
      try do
        endpoints = config[:endpoints] || Application.get_env(:kaffe, :endpoints)

        endpoints =
          Enum.map(endpoints, fn
            {host, port} ->
              {to_charlist(host), port}

            endpoint when is_binary(endpoint) ->
              case String.split(endpoint, ":") do
                [host, port] -> {to_charlist(host), String.to_integer(port)}
                [host] -> {to_charlist(host), 9092}
              end
          end)

        if is_list(endpoints) and not Enum.empty?(endpoints) do
          case :brod.get_metadata(endpoints, :all) do
            {:ok, _} ->
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

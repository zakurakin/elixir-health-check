defmodule HealthCheck.Checkers.Kafka do
  @moduledoc false
  require Logger

  def check(config \\ []) do
    if kaffe_started?() do
      do_check(config)
    else
      :ok
    end
  end

  defp kaffe_started? do
    Code.ensure_loaded?(Kaffe.Producer) and
      Enum.any?(Application.started_applications(), fn {app, _, _} -> app == :kaffe end)
  end

  defp do_check(config) do
    endpoints = config[:endpoints]
    normalized_endpoints = normalize_endpoints(endpoints)

    case check_kafka_metadata(normalized_endpoints) do
      :ok -> :ok
      {:error, reason} -> handle_error(reason)
    end
  rescue
    e ->
      Logger.error("Kafka health check failed: #{inspect(e)}")
      {:error, :kafka_exception}
  end

  defp normalize_endpoints(nil), do: []

  defp normalize_endpoints(endpoints) do
    Enum.map(endpoints, fn
      {host, port} ->
        {to_charlist(host), port}

      endpoint when is_binary(endpoint) ->
        case String.split(endpoint, ":") do
          [host, port] -> {to_charlist(host), String.to_integer(port)}
          [host] -> {to_charlist(host), 9092}
        end
    end)
  end

  defp check_kafka_metadata([]), do: {:error, :no_endpoints}

  defp check_kafka_metadata(endpoints) when is_list(endpoints) do
    :brod.get_metadata(endpoints, :all)
  end

  defp handle_error(:no_endpoints) do
    Logger.warning("Kafka health check: no endpoints configured")
    :ok
  end

  defp handle_error(reason) do
    Logger.error("Kafka health check failed: #{inspect(reason)}")
    {:error, :kafka_metadata_error}
  end
end

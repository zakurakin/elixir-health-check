defmodule HealthCheck do
  @moduledoc """
  Provides functions to check the health of the application and its dependencies.
  """

  @doc """
  Checks the health of specified dependencies.
  """
  def check(checks) when is_list(checks) do
    results =
      for {name, config} <- checks do
        status =
          case name do
            :postgres -> HealthCheck.Checkers.Postgres.check(config)
            :redis -> HealthCheck.Checkers.Redis.check(config)
            :kafka -> HealthCheck.Checkers.Kafka.check(config)
            :endpoint -> HealthCheck.Checkers.Endpoint.check(config)
            :mongo -> HealthCheck.Checkers.Mongo.check(config)
            _ -> do_check(config)
          end

        {name, status}
      end

    if Enum.all?(results, fn {_name, status} -> status == :ok end) do
      :ok
    else
      failed_deps =
        results
        |> Enum.filter(fn {_name, status} -> status != :ok end)
        |> Enum.map(fn {name, _status} -> name end)

      {:error, failed_deps}
    end
  end

  defp do_check({m, f, a}), do: apply(m, f, a)
  defp do_check(fun) when is_function(fun, 0), do: fun.()
  defp do_check(_), do: :ok
end

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
            _ -> execute(config)
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

  @doc false
  def execute({m, f, a}), do: apply(m, f, a)
  def execute(fun) when is_function(fun, 0), do: fun.()
  def execute(_), do: :ok
end

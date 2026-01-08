defmodule HealthCheck do
  @moduledoc """
  Provides functions to check the health of the application and its dependencies.
  """

  @doc """
  Checks the health of specified dependencies.
  """
  def check(checks) when is_list(checks) do
    results =
      for {name, {module, function, args}} <- checks do
        {name, apply(module, function, args)}
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
end

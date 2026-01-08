defmodule HealthCheck.Checkers.Postgres do
  @moduledoc false
  require Logger

  def check(repos) when is_list(repos) do
    Enum.reduce(repos, :ok, fn repo, acc ->
      if acc == :ok do
        check_repo(repo)
      else
        acc
      end
    end)
  end

  defp check_repo(repo) do
    if Code.ensure_loaded?(repo) do
      try do
        Ecto.Adapters.SQL.query!(repo, "SELECT 1", [], [timeout: 5000])
        :ok
      rescue
        e ->
          Logger.error("Health check failed for #{inspect(repo)}: #{inspect(e)}")
          {:error, repo}
      end
    else
      :ok
    end
  end
end

defmodule HealthCheckTest do
  use ExUnit.Case
  doctest HealthCheck

  test "check/1 returns :ok when all checks pass" do
    checks = [
      test: {__MODULE__, :pass_check, []}
    ]

    assert HealthCheck.check(checks) == :ok
  end

  test "check/1 returns {:error, failed_deps} when some checks fail" do
    checks = [
      pass: {__MODULE__, :pass_check, []},
      fail: {__MODULE__, :fail_check, []}
    ]

    assert HealthCheck.check(checks) == {:error, [:fail]}
  end

  def pass_check, do: :ok
  def fail_check, do: {:error, :failed}
end

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

  test "execute/1 handles different callables" do
    assert HealthCheck.execute(fn -> :ok end) == :ok
    assert HealthCheck.execute({__MODULE__, :pass_check, []}) == :ok
    assert HealthCheck.execute(nil) == :ok
  end

  def pass_check, do: :ok
  def fail_check, do: {:error, :failed}
end

defmodule HealthCheck.Checkers.EndpointTest do
  use ExUnit.Case
  alias HealthCheck.Checkers.Endpoint

  test "check/1 returns :ok if endpoint is empty" do
    assert Endpoint.check([endpoint: ""]) == :ok
    assert Endpoint.check([]) == :ok
  end
end

defmodule HealthCheck.Checkers.MongoTest do
  use ExUnit.Case
  alias HealthCheck.Checkers.Mongo

  test "check/1 returns :ok if Mongo is not loaded" do
    assert Mongo.check([topology: :some_topology]) == :ok
  end
end

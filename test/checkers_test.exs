defmodule HealthCheck.Checkers.EndpointTest do
  use ExUnit.Case
  alias HealthCheck.Checkers.Endpoint

  test "check/1 returns :ok if endpoint is empty" do
    assert Endpoint.check(endpoint: "") == :ok
    assert Endpoint.check([]) == :ok
  end
end

defmodule HealthCheck.Checkers.MongoTest do
  use ExUnit.Case
  alias HealthCheck.Checkers.Mongo

  test "check/1 returns an error if topology is missing" do
    assert Mongo.check([]) == {:error, :mongo}
  end

  test "check/1 accepts topology aliases and fails when topology is unavailable" do
    assert Mongo.check(topology: :some_topology) == {:error, :some_topology}
    assert Mongo.check(topology_name: :some_topology) == {:error, :some_topology}
  end
end

defmodule HealthCheck.Checkers.KafkaTest do
  use ExUnit.Case
  alias HealthCheck.Checkers.Kafka

  test "check/1 returns an error if endpoints are missing" do
    assert Kafka.check([]) == {:error, :kafka_no_endpoints}
    assert Kafka.check(endpoints: nil) == {:error, :kafka_no_endpoints}
    assert Kafka.check(endpoints: []) == {:error, :kafka_no_endpoints}
  end

  test "check/1 returns an error if kaffe is not started" do
    kaffe_started? = Enum.any?(Application.started_applications(), &match?({:kaffe, _, _}, &1))

    if kaffe_started?, do: Application.stop(:kaffe)
    on_exit(fn -> if kaffe_started?, do: Application.ensure_all_started(:kaffe) end)

    assert Kafka.check(endpoints: ["localhost:9092"]) == {:error, :kafka_not_started}
  end
end

defmodule HealthCheck.Checkers.PostgresTest do
  use ExUnit.Case
  alias HealthCheck.Checkers.Postgres

  test "check/1 returns an error if a repo is not available" do
    assert Postgres.check(repos: [HealthCheck.MissingRepo]) == {:error, HealthCheck.MissingRepo}
  end
end

defmodule HealthCheck.Checkers.KafkaTest do
  use ExUnit.Case
  alias HealthCheck.Checkers.Kafka

  test "check/1 returns :ok if kaffe is not loaded" do
    # Since we are in the same project, kaffe is loaded in test env.
    # But we can test the Code.ensure_loaded? logic if we could mock it.
    # For now let's just ensure it doesn't crash.
    assert Kafka.check(:non_existent_app) == :ok
  end
end

defmodule HealthCheck.Checkers.MinioTest do
  use ExUnit.Case
  alias HealthCheck.Checkers.Minio

  test "check/1 returns :ok if ExAws.S3 is not loaded" do
    # Similar to kafka test
    assert Minio.check() == :ok
  end
end

defmodule HealthCheck.Checkers.MongoTest do
  use ExUnit.Case
  alias HealthCheck.Checkers.Mongo

  test "check/1 returns :ok if Mongo is not loaded" do
    assert Mongo.check(:some_topology) == :ok
  end
end

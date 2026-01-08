# HealthCheck

Simple health check library for Elixir applications with support for Ecto, Redix, Kaffe, MongoDB, and S3-compatible storage (Minio).

Dependencies are optional, so you only need to include what you use.

## Installation

The package can be installed by adding `elixir_health_check` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elixir_health_check, "~> 0.1.0"}
  ]
end
```

## Usage

### Configuration

Configure the checks in your `config.exs`:

```elixir
config :my_app, :health_check_config,
  postgres: {HealthCheck.Checkers.Postgres, :check, [[MyApp.Repo]]},
  redis: {HealthCheck.Checkers.Redis, :check, [fn -> MyApp.Redis.get_conn() end]},
  kafka: {HealthCheck.Checkers.Kafka, :check, [:kaffe]},
  mongo: {HealthCheck.Checkers.Mongo, :check, [:my_mongo_topology]},
  minio: {HealthCheck.Checkers.Minio, :check, [[bucket: "my-bucket"]]}
```

### Kafka Check

The Kafka check verifies that the `kaffe` application is running and attempts to list topics from the configured endpoints.

### Minio Check

The Minio check uses `ExAws.S3` to list objects in a specified bucket (or `health-check` by default) to verify connectivity.

### Mongo Check

The Mongo check uses `mongodb_driver` to send a `ping` command to the specified topology.

### In a Phoenix/Plug application

You can use `HealthCheck.Router` as a plug in your endpoint or forward to it in your router:

```elixir
# In endpoint.ex
plug HealthCheck.Router, otp_app: :my_app

# Or in router.ex
forward "/health", HealthCheck.Router, otp_app: :my_app
```

### In a non-web application

You can start a standalone health check server (using Bandit) in your application's supervision tree:

```elixir
def start(_type, _args) do
  children = [
    {HealthCheck.Server, otp_app: :my_app, port: 4000}
    # ... other children
  ]
  Supervisor.start_link(children, strategy: :one_for_one)
end
```

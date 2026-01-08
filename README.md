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

Configure the checks in your `config.exs`. The configuration is a keyword list where keys are dependency names and values are their respective configurations.

```elixir
config :my_app, :health_check_config,
  postgres: [repos: [MyApp.Repo]],
  redis: [redis_conn_selector: fn -> MyApp.Redis.get_conn() end],
  kafka: [],
  mongo: [topology: :my_mongo_topology],
  endpoint: [endpoint: "http://minio:9000/minio/health/live"]
```

The library provides default checkers for:
- `:postgres` (requires `:repos`)
- `:redis` (requires `:redis_conn_selector`)
- `:kafka` (optional `:endpoints`)
- `:mongo` (requires `:topology`)
- `:endpoint` (requires `:endpoint`)

### Postgres Check

Verifies connectivity to one or more Ecto repositories by executing `SELECT 1`.

### Redis Check

Verifies connectivity to Redis by sending a `PING` command. You must provide a function that returns a connection (pid or atom).

### Kafka Check

The Kafka check verifies that the `kaffe` application is running and attempts to list topics from the configured endpoints using `:brod`.

### Endpoint Check

The Endpoint check uses `HTTPoison` to verify connectivity to a specified URL. It expects a status code less than 500.

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

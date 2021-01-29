defmodule SlackTest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SlackTest.Repo,
      # Start the Telemetry supervisor
      SlackTestWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SlackTest.PubSub},
      # Start the Endpoint (http/https)
      SlackTestWeb.Endpoint
      # Start a worker by calling: SlackTest.Worker.start_link(arg)
      # {SlackTest.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SlackTest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SlackTestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

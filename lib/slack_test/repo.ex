defmodule SlackTest.Repo do
  use Ecto.Repo,
    otp_app: :slack_test,
    adapter: Ecto.Adapters.Postgres

  def cursor_paginate(queryable, opts \\ [], repo_opts \\ []) do
    defaults = [limit: 10, maximum_limit: 100, include_total_count: true]
    opts = Keyword.merge(defaults, opts)
    Paginator.paginate(queryable, opts, __MODULE__, repo_opts)
  end
end

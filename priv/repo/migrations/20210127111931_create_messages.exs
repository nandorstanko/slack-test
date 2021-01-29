defmodule SlackTest.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :subject, :string
      add :body, :text
      add :slack_channel, :string
      add :slack_timestamp, :string

      timestamps()
    end

  end
end

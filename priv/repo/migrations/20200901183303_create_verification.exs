defmodule Euler.Repo.Migrations.CreateVerification do
  use Ecto.Migration

  def change do
    create table(:verification) do
      add :input, :string
      add :result, :boolean

      timestamps(updated_at: false)
    end
  end

end

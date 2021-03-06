defmodule Euler do
  @moduledoc """
  Euler keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Euler.Verification
  alias Euler.INNVerification
  alias Euler.Cache
  alias Euler.Repo

  @spec latest(pos_integer()) :: [Verification.t()]
  def latest(n) do
    Verification.latest(n)
    |> Repo.all
  end

  # Эта функция не нарушает принцип единой ответственности
  # потому что эта функция верхнего доменного уровня и она выполняет роль
  # функции вызываемой из веб-приложения
  @spec verify(String.t()) :: {:ok, Verification.t()} | {:error, Ecto.Changeset.t()}
  def verify(inn_string) do
    inn_string
    |> get_verified()
    |> Verification.create_changeset()
    |> Repo.insert()
  end

  @spec get_verified(String.t()) :: INNVerification.t()
  defp get_verified(inn_string) do
    inn_string
    |> Cache.get_lazy(fn -> INNVerification.verify(inn_string) end)
    |> case do
      {:ok, value} -> value
      _ -> INNVerification.verify(inn_string)
    end
  end

end

defmodule Euler.INNVerification do

  @moduledoc """
  Main application logic here
  """

  alias Euler.Verification
  alias Euler.Repo

  @ten_coef     [2, 4, 10, 3, 5, 9, 4, 6, 8]
  @twelve_coef1 [7, 2, 4, 10, 3, 5, 9, 4, 6, 8]
  @twelve_coef2 [3, 7, 2, 4, 10, 3, 5, 9, 4, 6, 8]

  @spec latest(pos_integer()) :: [Verification.t()]
  def latest(n) do
    Verification.latest(n)
    |> Repo.all
  end

  @spec verify(String.t()) :: {:ok, Verification.t()} | {:error, Ecto.Changeset.t()}
  def verify(inn_string) do
    inn_string
    |> just_verify()
    |> Verification.create_changeset()
    |> Repo.insert()
  end

  @spec just_verify(String.t()) :: Map.t()
  def just_verify(inn_string) do
    with {:ok, inn} <- parse(inn_string) do
      do_verify(inn)
    end
    |> case do
      {:ok, true} -> %{input: inn_string, result: true}
      _           -> %{input: inn_string, result: false}
    end
  end

  @spec parse(String.t()) :: {:ok, integer()} | {:error, :bad_string}
  defp parse(inn_string) do
    case Integer.parse(inn_string) do
      {int, ""} -> {:ok, int}
      _         -> {:error, :bad_string}
    end
  end

  @spec do_verify(integer()) :: {:ok, boolean()} | {:error, :bad_integer}
  defp do_verify(inn) when inn > 0 do
    case Integer.digits(inn) do
      [_, _, _, _, _, _, _, _, _, a10] = digits ->
        {:ok, check(digits, @ten_coef, a10)}

      [_, _, _, _, _, _, _, _, _, _, a11, a12] = digits ->
        {:ok, check(digits, @twelve_coef1, a11) && check(digits, @twelve_coef2, a12)}

      _ ->
        {:error, :bad_integer}
    end
  end
  defp do_verify(_), do: {:error, :bad_integer}

  @spec check([integer()], [integer()], integer()) :: boolean()
  defp check(digits, coefs, checker) do
    sum = vmult(digits, coefs)
    rem(rem(sum, 11), 10) == checker
  end

  @spec vmult([integer()], [integer()]) :: integer()
  defp vmult(left, right) do
    left
    |> Enum.zip(right)
    |> Enum.reduce(0, fn {x, y}, acc -> acc + x * y end)
  end

end

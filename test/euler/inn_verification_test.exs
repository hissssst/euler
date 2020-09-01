defmodule Euler.INNVerificationTest do

  use ExUnit.Case
  alias Euler.INNVerification

  @bad_inputs ["123412312", "xasdca1234123"]
  @good_inputs ["500100732259", "7830002293"]


  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Euler.Repo)
  end

  test "just verifications" do
    Enum.map(@good_inputs, fn input ->
      assert %{result: true} = INNVerification.just_verify(input)
    end)
    Enum.map(@bad_inputs, fn input ->
      assert %{result: true} != INNVerification.just_verify(input)
    end)
  end

  test "verifications" do
    Enum.map(@good_inputs, fn input ->
      assert {:ok, %{result: true}} = INNVerification.verify(input)
    end)
    Enum.map(@bad_inputs, fn input ->
      assert {:ok, %{result: true}} != INNVerification.just_verify(input)
    end)
  end
end

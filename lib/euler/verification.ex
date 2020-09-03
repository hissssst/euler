defmodule Euler.Verification do

  @moduledoc """
  Verification table schema
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  schema "verification" do
    field :input,  :string
    field :result, :boolean

    timestamps updated_at: false
  end

  @type t :: %__MODULE__{
    input:       String.t(),
    result:      boolean(),
    inserted_at: DateTime.t()
  }

  @spec create_changeset(map()) :: Ecto.Changeset.t()
  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, ~w[input result]a)
    |> validate_required(~w[input result]a)
  end

  @spec latest(pos_integer()) :: Ecto.Query.t()
  def latest(n) when is_integer(n) and n > 0 do
    from x in __MODULE__,
      order_by: [desc: x.inserted_at],
      limit: ^n
  end

end

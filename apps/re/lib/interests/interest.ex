defmodule Re.Interest do
  @moduledoc """
  Schema module for storing interest in a listing
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Re.{
    Accounts.Users,
    BuyerLead
  }

  schema "interests" do
    field :uuid, Ecto.UUID
    field :name, :string
    field :email, :string
    field :phone, :string
    field :message, :string

    belongs_to :listing, Re.Listing
    belongs_to :interest_type, Re.InterestType

    timestamps()
  end

  @required ~w(name phone listing_id)a
  @optional ~w(email message interest_type_id uuid)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:listing_id,
      name: :interests_listing_id_fkey,
      message: "does not exist."
    )
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)

  def buyer_lead_changeset(nil), do: raise("Interest not found")

  def buyer_lead_changeset(interest) do
    params =
      %{
        name: interest.name,
        email: interest.email,
        origin: "site"
      }
      |> put_location(interest)
      |> put_user_info(interest)

    BuyerLead.changeset(%BuyerLead{}, params)
  end

  defp put_location(params, %{listing: %{address: address} = listing}) do
    params
    |> Map.put(:location, "#{address.city_slug}|#{address.state_slug}")
    |> Map.put(:listing_uuid, listing.uuid)
    |> Map.put(:neighborhood, address.neighborhood)
  end

  defp put_user_info(params, %{phone: nil}), do: params

  defp put_user_info(params, interest) do
    phone_number = String.replace(interest.phone, ["(", ")", "-", " "], "")

    phone_number
    |> Users.get_by_phone()
    |> case do
      {:ok, user} -> Map.put(params, :user_uuid, user.uuid)
      {:error, :not_found} -> params
    end
    |> Map.put(:phone_number, phone_number)
  end
end

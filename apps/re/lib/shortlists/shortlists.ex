defmodule Re.Shortlists do
  @moduledoc """
  Context for shortlists.
  """

  alias __MODULE__.{
    Client,
    Salesforce.Opportunity
  }

  alias Re.{
    Listing,
    Listings.Queries,
    Repo,
    Salesforce
  }

  @behaviour Bodyguard.Policy

  defdelegate authorize(action, user, params), to: Re.Shortlists.Policy

  def generate_shortlist_from_salesforce_opportunity(opportunity_id) do
    with {:ok, opportunity} <- Salesforce.get_opportunity(opportunity_id),
         {:ok, params} <- Opportunity.build(opportunity),
         {:ok, listing_uuids} <- get_shortlist(params) do
      get_active_listings_by_uuid(listing_uuids)
    else
      _error -> {:error, :invalid_opportunity}
    end
  end

  defp get_shortlist(params) do
    with {:ok, %{body: body}} <- Client.get_listings_uuids(params) do
      Jason.decode(body)
    end
  end

  defp get_active_listings_by_uuid(uuids) do
    Listing
    |> Queries.with_uuids(uuids)
    |> Queries.active()
    |> Repo.all()
  end
end

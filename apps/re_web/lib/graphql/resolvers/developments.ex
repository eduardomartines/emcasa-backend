defmodule ReWeb.Resolvers.Developments do
  @moduledoc false

  alias Re.{
    Addresses,
    Development,
    Developments,
    Developments.Typologies
  }

  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  def index(_params, _context) do
    developments = Developments.all()

    {:ok, developments}
  end

  def show(%{uuid: uuid}, _context) do
    Developments.get(uuid)
  end

  def insert(%{input: development_params}, %{context: %{current_user: current_user}}) do
    with :ok <-
           Bodyguard.permit(Developments, :insert_development, current_user, development_params),
         {:ok, address} <- get_address(development_params),
         {:ok, development} <- Developments.insert(development_params, address) do
      {:ok, development}
    else
      {:error, _, error, _} -> {:error, error}
      error -> error
    end
  end

  def per_listing(listing, _params, %{context: %{loader: loader}}) do
    loader
    |> Dataloader.load(Developments, :development, listing)
    |> on_load(fn loader ->
      {:ok, Dataloader.get(loader, Developments, :development, listing)}
    end)
  end

  def typologies(development, _params, %{context: %{loader: loader}}) do
    loader
    |> Dataloader.load(Typologies, Development, development.uuid)
    |> on_load(fn loader ->
      %{typologies: typologies} =
        Dataloader.get(loader, Typologies, Development, development.uuid)

      {:ok, typologies}
    end)
  end

  def update(%{uuid: uuid, input: development_params}, %{
        context: %{current_user: current_user}
      }) do
    with {:ok, development} <- Developments.get(uuid),
         :ok <- Bodyguard.permit(Developments, :update_development, current_user, development),
         {:ok, address} <- get_address(development_params),
         {:ok, development} <- Developments.update(development, development_params, address) do
      {:ok, development}
    end
  end

  def import_from_orulo(%{external_id: id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Developments, :import_development_from_orulo, current_user),
         {:ok, _job} <- ReIntegrations.Orulo.get_building_payload(id) do
      {:ok, %{message: "Development syncronization scheduled!"}}
    end
  end

  defp get_address(%{address_id: id}), do: Addresses.get_by_id(id)
  defp get_address(_), do: {:error, :bad_request}
end

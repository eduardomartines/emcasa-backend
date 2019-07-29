defmodule Re.AlikeTeller do
  @moduledoc """
  Module to interface with aliketeller for related listings
  """
  require Logger

  alias __MODULE__.{
    Client,
    Server
  }

  @spec get(String.t()) :: {:error, :not_found} | {:ok, list(String.t())}
  def get(uuid) do
    case :ets.lookup(:aliketeller, uuid) do
      [] -> {:error, :not_found}
      [{_uuid, uuids}] -> {:ok, uuids}
    end
  end

  def load, do: GenServer.cast(Server, :load_aliketeller)

  def create_ets_table do
    case :ets.whereis(:aliketeller) do
      :undefined ->
        :ets.new(:aliketeller, [:set, :protected, :named_table, read_concurrency: true])

      _ ->
        :ok
    end
  end

  def load_aliketeller do
    create_ets_table()

    with {:ok, %{status_code: 200, body: body}} <- Client.get_payload(),
         {:ok, payload} <- Jason.decode(body) do
      save_on_ets(payload)
    else
      error ->
        Logger.warn("Error loading aliketeller payload: #{inspect(error)}")

        error
    end
  end

  defp save_on_ets(%{"data" => data}), do: Enum.each(data, &do_save_on_ets/1)

  defp do_save_on_ets(%{"listing_uuid" => uuid, "suggested_listing_uuids" => uuids}) do
    :ets.insert(:aliketeller, {uuid, uuids})
  end
end

defmodule Re.Units.Policy do
  @moduledoc """
  Policy module for user permission on units
  """

  alias Re.User

  def authorize(_, %User{role: "admin"}, _), do: :ok
  def authorize(_, nil, _), do: {:error, :unauthorized}

  def authorize(_, _, _), do: {:error, :forbidden}
end

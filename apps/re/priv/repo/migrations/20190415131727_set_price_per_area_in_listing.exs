defmodule Re.Repo.Migrations.SetPricePerAreaInListing do
  use Ecto.Migration

  import Ecto.Query

  def up do
    query =
      from(
        l in "listings",
        update: [set: [price_per_area: l.price / l.area]],
        where: l.price > 0 and l.area > 0
      )

    Re.Repo.update_all(query, [])
  end

  def down do
    Re.Repo.update_all("listings", set: [price_per_area: nil])
  end
end

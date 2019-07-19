defmodule Re.Listings.HighlightsTest do
  use Re.ModelCase

  alias Re.{
    Address,
    Listings.Highlights
  }

  import Re.Factory

  @valid_attributes_rj %{
    price: 1_999_999,
    rooms: 3,
    garage_spots: 1,
    area: 100,
    address: %Address{
      neighborhood_slug: "botafogo",
      city_slug: "rio-de-janeiro",
      state_slug: "rj"
    }
  }

  @valid_attributes_sp %{
    price: 2_000_000,
    rooms: 3,
    garage_spots: 2,
    area: 100,
    address: %Address{
      neighborhood_slug: "perdizes",
      city_slug: "sao-paulo",
      state_slug: "sp"
    }
  }

  describe "get_highlight_listing_ids/2" do
    test "should filter by city and state slug" do
      %{id: id1} = insert(:listing, @valid_attributes_sp)

      insert(:listing, @valid_attributes_rj)

      filters =
        Map.put(
          %{},
          :filters,
          %{cities_slug: ["sao-paulo"], states_slug: ["sp"]}
        )

      assert [^id1] = Highlights.get_highlight_listing_ids(filters)
    end

    test "should consider page_size value" do
      insert_list(2, :listing, @valid_attributes_rj)

      result = Highlights.get_highlight_listing_ids(%{page_size: 1})
      assert 1 = length(result)
    end

    test "should consider offset value" do
      insert_list(2, :listing, @valid_attributes_rj)

      result = Highlights.get_highlight_listing_ids(%{offset: 1})
      assert 1 = length(result)
    end

    test "should consider listings with prices bellow 2 millions" do
      %{id: listing_id_valid} = insert(:listing, @valid_attributes_rj)

      invalid_attributes = Map.merge(@valid_attributes_rj, %{price: 2_000_001})
      insert(:listing, invalid_attributes)

      assert [listing_id_valid] == Highlights.get_highlight_listing_ids()
    end

    test "should consider listings with less than 4 rooms" do
      %{id: listing_id_valid} = insert(:listing, @valid_attributes_rj)

      invalid_attributes = Map.merge(@valid_attributes_rj, %{rooms: 4})
      insert(:listing, invalid_attributes)

      assert [listing_id_valid] == Highlights.get_highlight_listing_ids()
    end

    test "should consider listings with more than 1 garage spot" do
      %{id: listing_id_valid} = insert(:listing, @valid_attributes_rj)

      invalid_attributes = Map.merge(@valid_attributes_rj, %{garage_spots: 0})
      insert(:listing, invalid_attributes)

      assert [listing_id_valid] == Highlights.get_highlight_listing_ids()
    end

    test "should sort by recents" do
      [%{id: listing_id_1}, %{id: listing_id_2}] = insert_list(2, :listing, @valid_attributes_rj)

      assert [listing_id_2, listing_id_1] == Highlights.get_highlight_listing_ids()
    end
  end
end

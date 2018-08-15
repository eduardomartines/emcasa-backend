defmodule ReWeb.GraphQL.Addresses.InsertTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_user: admin_user,
     user_user: user_user,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  test "admin should insert address", %{admin_conn: conn} do
    address = build(:address)

    mutation = """
      mutation {
        addressInsert(input: {
          city: "#{address.city}",
          state: "#{address.state}",
          lat: #{address.lat},
          lng: #{address.lng},
          neighborhood: "#{address.neighborhood}",
          street: "#{address.street}",
          streetNumber: "#{address.street_number}",
          postalCode: "#{address.postal_code}"
        }) {
          city
          state
          lat
          lng
          neighborhood
          street
          streetNumber
          postalCode
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{
               "city" => address.city,
               "state" => address.state,
               "lat" => address.lat,
               "lng" => address.lng,
               "neighborhood" => address.neighborhood,
               "street" => address.street,
               "streetNumber" => address.street_number,
               "postalCode" => address.postal_code
           } == json_response(conn, 200)["data"]["addressInsert"]
  end

  test "user should insert address", %{user_conn: conn} do
    address = build(:address)

    mutation = """
      mutation {
        addressInsert(input: {
          city: "#{address.city}",
          state: "#{address.state}",
          lat: #{address.lat},
          lng: #{address.lng},
          neighborhood: "#{address.neighborhood}",
          street: "#{address.street}",
          streetNumber: "#{address.street_number}",
          postalCode: "#{address.postal_code}"
        }) {
          city
          state
          lat
          lng
          neighborhood
          street
          streetNumber
          postalCode
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{
               "city" => address.city,
               "state" => address.state,
               "lat" => address.lat,
               "lng" => address.lng,
               "neighborhood" => address.neighborhood,
               "street" => address.street,
               "streetNumber" => address.street_number,
               "postalCode" => address.postal_code
           } == json_response(conn, 200)["data"]["addressInsert"]
  end

  test "admin should update address", %{admin_conn: conn} do
    address = insert(:address)

    mutation = """
      mutation {
        addressInsert(input: {
          city: "#{address.city}",
          state: "#{address.state}",
          lat: #{address.lat},
          lng: #{address.lng},
          neighborhood: "#{address.neighborhood}",
          street: "#{address.street}",
          streetNumber: "#{address.street_number}",
          postalCode: "#{address.postal_code}"
        }) {
          id
          city
          state
          lat
          lng
          neighborhood
          street
          streetNumber
          postalCode
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{
               "id" => to_string(address.id),
               "city" => address.city,
               "state" => address.state,
               "lat" => address.lat,
               "lng" => address.lng,
               "neighborhood" => address.neighborhood,
               "street" => address.street,
               "streetNumber" => address.street_number,
               "postalCode" => address.postal_code
           } == json_response(conn, 200)["data"]["addressInsert"]
  end

  test "user should update address", %{user_conn: conn} do
    address = insert(:address)

    mutation = """
      mutation {
        addressInsert(input: {
          city: "#{address.city}",
          state: "#{address.state}",
          lat: #{address.lat},
          lng: #{address.lng},
          neighborhood: "#{address.neighborhood}",
          street: "#{address.street}",
          streetNumber: "#{address.street_number}",
          postalCode: "#{address.postal_code}"
        }) {
          id
          city
          state
          lat
          lng
          neighborhood
          street
          streetNumber
          postalCode
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert %{
               "id" => to_string(address.id),
               "city" => address.city,
               "state" => address.state,
               "lat" => address.lat,
               "lng" => address.lng,
               "neighborhood" => address.neighborhood,
               "street" => address.street,
               "streetNumber" => address.street_number,
               "postalCode" => address.postal_code
           } == json_response(conn, 200)["data"]["addressInsert"]
  end

  test "anonymous should not insert image", %{unauthenticated_conn: conn} do
    address = build(:address)

    mutation = """
      mutation {
        addressInsert(input: {
          city: "#{address.city}",
          state: "#{address.state}",
          lat: #{address.lat},
          lng: #{address.lng},
          neighborhood: "#{address.neighborhood}",
          street: "#{address.street}",
          streetNumber: "#{address.street_number}",
          postalCode: "#{address.postal_code}"
        }) {
          city
          state
          lat
          lng
          neighborhood
          street
          streetNumber
          postalCode
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

    assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
  end
end

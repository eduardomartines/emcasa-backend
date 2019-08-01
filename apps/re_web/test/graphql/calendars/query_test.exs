defmodule ReWeb.GraphQL.Calendars.QueryTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  test "admin should query tour options", %{admin_conn: conn} do
    query = """
      query TourOptions {
        tourOptions
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert [_, _, _, _, _, _, _, _, _, _] = json_response(conn, 200)["data"]["tourOptions"]
  end

  test "user should query tour options", %{user_conn: conn} do
    query = """
      query TourOptions {
        tourOptions
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert [_, _, _, _, _, _, _, _, _, _] = json_response(conn, 200)["data"]["tourOptions"]
  end

  test "anonymous should not query tour options", %{unauthenticated_conn: conn} do
    query = """
      query TourOptions {
        tourOptions
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

    assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
  end
end

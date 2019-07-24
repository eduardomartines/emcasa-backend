defmodule ReWeb.GraphQL.Accounts.MutationTest do
  use ReWeb.ConnCase

  import Re.Factory

  use ReWeb.AbsintheAssertions
  alias ReWeb.AbsintheHelpers
  alias Re.User

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")
    partner_user = insert(:user, email: "user@email.com", role: "user", type: "partner")

    {:ok,
     unauthenticated_conn: conn,
     admin_user: admin_user,
     user_user: user_user,
     partner_user: partner_user,
     admin_conn: login_as(conn, admin_user),
     partner_conn: login_as(conn, partner_user),
     user_conn: login_as(conn, user_user)}
  end

  describe "activateListing" do
    test "admin should get favorited listings", %{admin_conn: conn, admin_user: user} do
      listing = insert(:listing)
      insert(:listings_favorites, listing_id: listing.id, user_id: user.id)

      query = """
        query FavoritedListings {
          favoritedListings {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      listing_id = to_string(listing.id)
      assert [%{"id" => listing_id}] == json_response(conn, 200)["data"]["favoritedListings"]
    end

    test "user should get favorited listings", %{user_conn: conn, user_user: user} do
      listing = insert(:listing)
      insert(:listings_favorites, listing_id: listing.id, user_id: user.id)

      query = """
        query FavoritedListings {
          favoritedListings {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      listing_id = to_string(listing.id)
      assert [%{"id" => listing_id}] == json_response(conn, 200)["data"]["favoritedListings"]
    end

    test "anonymous should not get favorited listing", %{unauthenticated_conn: conn} do
      query = """
        query FavoritedListings {
          favoritedListings {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query))

      [errors] = json_response(conn, 200)["errors"]

      assert errors["message"] == "Unauthorized"
      assert errors["code"] == 401
    end
  end

  describe "editUserProfile" do
    test "admin should edit any profile", %{admin_conn: conn, user_user: user} do
      variables = %{
        "id" => user.id,
        "name" => "Fixed Name",
        "phone" => "123321123",
        "notificationPreferences" => %{
          "email" => false,
          "app" => false
        },
        "deviceToken" => "asdasdasd"
      }

      mutation = """
        mutation EditUserProfile($id: ID!, $name: String, $phone: String, $notificationPreferences: NotificationPreferencesInput, $deviceToken: String) {
          editUserProfile(
            id: $id,
            name: $name,
            phone: $phone,
            notificationPreferences: $notificationPreferences,
            deviceToken: $deviceToken
          ){
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{"id" => to_string(user.id)} == json_response(conn, 200)["data"]["editUserProfile"]

      assert user = Repo.get(User, user.id)
      assert user.name == "Fixed Name"
      assert user.phone == "123321123"
      assert user.device_token == "asdasdasd"
      refute user.notification_preferences.email
      refute user.notification_preferences.app
    end

    test "user should edit own profile", %{user_conn: conn, user_user: user} do
      variables = %{
        "id" => user.id,
        "name" => "Fixed Name",
        "phone" => "123321123",
        "notificationPreferences" => %{
          "email" => false,
          "app" => false
        },
        "deviceToken" => "asdasdasd"
      }

      mutation = """
        mutation EditUserProfile($id: ID!, $name: String, $phone: String, $notificationPreferences: NotificationPreferencesInput, $deviceToken: String) {
          editUserProfile(
            id: $id,
            name: $name,
            phone: $phone,
            notificationPreferences: $notificationPreferences,
            deviceToken: $deviceToken
          ){
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{"id" => to_string(user.id)} == json_response(conn, 200)["data"]["editUserProfile"]

      assert user = Repo.get(User, user.id)
      assert user.name == "Fixed Name"
      assert user.phone == "123321123"
      assert user.device_token == "asdasdasd"
      refute user.notification_preferences.email
      refute user.notification_preferences.app
    end

    test "user should not edit other user's  profile", %{user_conn: conn} do
      inserted_user = insert(:user)

      variables = %{
        "id" => inserted_user.id,
        "name" => "Fixed Name"
      }

      mutation = """
        mutation EditUserProfile($id: ID!, $name: String) {
          editUserProfile(id: $id, name: $name) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not edit user profile", %{unauthenticated_conn: conn} do
      user = insert(:user)

      variables = %{
        "id" => user.id,
        "name" => "Fixed Name"
      }

      mutation = """
        mutation EditUserProfile($id: ID!, $name: String) {
          editUserProfile(id: $id, name: $name) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end
  end

  describe "changeEmail" do
    test "admin should change email", %{admin_conn: conn} do
      user = insert(:user, email: "old_email@emcasa.com")

      variables = %{
        "id" => user.id,
        "email" => "newemail@emcasa.com"
      }

      mutation = """
        mutation ChangeEmail($id: ID!, $email: String) {
          changeEmail(id: $id, email: $email) {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert user = Repo.get(User, user.id)
      assert user.email == "newemail@emcasa.com"
    end

    test "user should change own email", %{user_conn: conn, user_user: user} do
      variables = %{
        "id" => user.id,
        "email" => "newemail@emcasa.com"
      }

      mutation = """
        mutation ChangeEmail($id: ID!, $email: String) {
          changeEmail(id: $id, email: $email) {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert user = Repo.get(User, user.id)
      assert user.email == "newemail@emcasa.com"
    end

    test "user should not edit other user's  email", %{user_conn: conn} do
      inserted_user = insert(:user)

      variables = %{
        "id" => inserted_user.id,
        "email" => "newemail@emcasa.com"
      }

      mutation = """
        mutation ChangeEmail($id: ID!, $email: String) {
          changeEmail(id: $id, email: $email) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not edit user profile", %{unauthenticated_conn: conn} do
      user = insert(:user)

      variables = %{
        "id" => user.id,
        "email" => "newemail@emcasa.com"
      }

      mutation = """
        mutation ChangeEmail($id: ID!, $email: String) {
          changeEmail(id: $id, email: $email) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end

    test "should fail when using existing e-mail", %{user_conn: conn, user_user: user} do
      insert(:user, email: "existing@emcasa.com")

      variables = %{
        "id" => user.id,
        "email" => "existing@emcasa.com"
      }

      mutation = """
        mutation ChangeEmail($id: ID!, $email: String) {
          changeEmail(id: $id, email: $email) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{"id" => to_string(user.id)} == json_response(conn, 200)["data"]["changeEmail"]
    end
  end

  describe "accountKitSignIn" do
    test "should register with account kit", %{unauthenticated_conn: conn} do
      variables = %{
        "accessToken" => "valid_access_token"
      }

      mutation = """
        mutation AccountKitSignIn($accessToken: String!) {
          accountKitSignIn(accessToken: $accessToken) {
            jwt
            user {
              phone
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "phone" => "+5511999999999"
             } == json_response(conn, 200)["data"]["accountKitSignIn"]["user"]

      assert json_response(conn, 200)["data"]["accountKitSignIn"]["jwt"]
    end

    test "should sign in with account kit", %{unauthenticated_conn: conn} do
      user = insert(:user, account_kit_id: "321", phone: "+5511999999999")

      variables = %{
        "accessToken" => "valid_access_token"
      }

      mutation = """
        mutation AccountKitSignIn($accessToken: String!) {
          accountKitSignIn(accessToken: $accessToken) {
            jwt
            user {
              id
              phone
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{
               "id" => to_string(user.id),
               "phone" => user.phone
             } == json_response(conn, 200)["data"]["accountKitSignIn"]["user"]

      assert json_response(conn, 200)["data"]["accountKitSignIn"]["jwt"]
    end

    test "should not sign in with invalid access token", %{unauthenticated_conn: conn} do
      variables = %{
        "accessToken" => "invalid_access_token"
      }

      mutation = """
        mutation AccountKitSignIn($accessToken: String!) {
          accountKitSignIn(accessToken: $accessToken) {
            jwt
            user {
              id
              phone
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      [errors] = json_response(conn, 200)["errors"]

      assert errors["message"] == "Invalid OAuth access token."
      assert errors["code"] == 190
    end
  end

  describe "userUpdateRole" do
    @update_role_mutation """
      mutation UserUpdateRole($uuid: UUID!, $role: UserRole) {
        userUpdateRole(uuid: $uuid, role: $role) {
          uuid
          role
        }
      }
    """

    test "admin can update user role", %{admin_conn: conn} do
      user = insert(:user)

      variables = %{
        "uuid" => user.uuid,
        "role" => "ADMIN"
      }

      conn =
        post(
          conn,
          "/graphql_api",
          AbsintheHelpers.mutation_wrapper(@update_role_mutation, variables)
        )
      assert %{"uuid" => user.uuid, "role" => "admin"} ==
               json_response(conn, 200)["data"]["userUpdateRole"]
    end

    test "common user cannot update user role", %{user_conn: conn} do
      user = insert(:user)

      variables = %{
        "uuid" => user.uuid,
        "role" => "ADMIN"
      }

      conn =
        post(
          conn,
          "/graphql_api",
          AbsintheHelpers.mutation_wrapper(@update_role_mutation, variables)
        )

      assert_forbidden_response(json_response(conn, 200))
      assert %{"userUpdateRole" => nil} == json_response(conn, 200)["data"]
    end

    test "unauthenticated user cannot update user role", %{unauthenticated_conn: conn} do
      user = insert(:user)

      variables = %{
        "uuid" => user.uuid,
        "role" => "ADMIN"
      }

      conn =
        post(
          conn,
          "/graphql_api",
          AbsintheHelpers.mutation_wrapper(@update_role_mutation, variables)
        )

      assert_unauthorized_response(json_response(conn, 200))
      assert %{"userUpdateRole" => nil} == json_response(conn, 200)["data"]
    end
  end

  describe "editPartnerBroker" do

    test "admin should edit any partner broker", %{admin_conn: conn, partner_user: user} do
      districts = insert_list(2, :district)
      districts_slug = Enum.map(districts, fn district -> district.name_slug end)
      variables = %{
        "id" => user.id,
        "name" => "Fixed Name",
        "phone" => "123321123",
        "notificationPreferences" => %{
          "email" => false,
          "app" => false
        },
        "deviceToken" => "asdasdasd",
        "districts" => districts_slug
      }

      mutation = """
        mutation EditPartnerBroker($id: ID!, $name: String, $phone: String, $notificationPreferences: NotificationPreferencesInput, $deviceToken: String, $districts: [String]!) {
          editPartnerBroker(
            id: $id,
            name: $name,
            phone: $phone,
            notificationPreferences: $notificationPreferences,
            deviceToken: $deviceToken,
            districts: $districts
          ){
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{"id" => to_string(user.id)} == json_response(conn, 200)["data"]["editPartnerBroker"]

      assert user = Repo.get(User, user.id) |> Repo.preload(:districts)
      assert user.name == "Fixed Name"
      assert user.phone == "123321123"
      assert user.device_token == "asdasdasd"
      refute user.notification_preferences.email
      refute user.notification_preferences.app
      assert user.districts == districts
    end

    test "broker should edit own profile", %{partner_conn: conn, partner_user: user} do
      districts = insert_list(2, :district)
      districts_slug = Enum.map(districts, fn district -> district.name_slug end)
      variables = %{
        "id" => user.id,
        "name" => "Fixed Name",
        "phone" => "123321123",
        "notificationPreferences" => %{
          "email" => false,
          "app" => false
        },
        "deviceToken" => "asdasdasd",
        "districts" => districts_slug
      }

      mutation = """
        mutation EditPartnerBroker($id: ID!, $name: String, $phone: String, $notificationPreferences: NotificationPreferencesInput, $deviceToken: String, $districts: [String]!) {
          editPartnerBroker(
            id: $id,
            name: $name,
            phone: $phone,
            notificationPreferences: $notificationPreferences,
            deviceToken: $deviceToken,
            districts: $districts
          ){
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert %{"id" => to_string(user.id)} == json_response(conn, 200)["data"]["editPartnerBroker"]

      assert user = Repo.get(User, user.id) |> Repo.preload(:districts)
      assert user.name == "Fixed Name"
      assert user.phone == "123321123"
      assert user.device_token == "asdasdasd"
      refute user.notification_preferences.email
      refute user.notification_preferences.app
      assert user.districts == districts
    end

    test "partner should not edit other user's  profile", %{partner_conn: conn} do
      inserted_user = insert(:user)
      districts = insert_list(2, :district)
      districts_slug = Enum.map(districts, fn district -> district.name_slug end)

      variables = %{
        "id" => inserted_user.id,
        "name" => "Fixed Name",
        "districts" => districts_slug
      }

      mutation = """
        mutation EditPartnerBroker($id: ID!, $name: String, $districts: [String]!) {
          editPartnerBroker(id: $id, name: $name, districts: $districts) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not edit partner profile", %{unauthenticated_conn: conn} do
      user = insert(:user)

      variables = %{
        "id" => user.id,
        "name" => "Fixed Name",
        "districts" => ["d1"]
      }

      mutation = """
        mutation EditPartnerBroker($id: ID!, $name: String, $districts: [String]!) {
          editPartnerBroker(id: $id, name: $name, districts: $districts) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_wrapper(mutation, variables))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end
  end
end

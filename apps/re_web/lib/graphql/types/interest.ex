defmodule ReWeb.Types.Interest do
  @moduledoc """
  GraphQL types for interests
  """
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias ReWeb.Resolvers.Interests, as: InterestsResolver

  object :interest do
    field :id, :id
    field :uuid, :uuid
    field :name, :string
    field :email, :string
    field :phone, :string
    field :message, :string
    field :campaign, :string
    field :medium, :string
    field :source, :string
    field :initial_campaign, :string
    field :initial_medium, :string
    field :initial_source, :string

    field :listing, :listing, resolve: dataloader(Re.Listings)
    field :interest_type, :interest_type, resolve: dataloader(Re.Interests.Types)
  end

  input_object :interest_input do
    field :name, :string
    field :phone, :string
    field :email, :string
    field :message, :string
    field :campaign, :string
    field :medium, :string
    field :source, :string
    field :initial_campaign, :string
    field :initial_medium, :string
    field :initial_source, :string

    field :interest_type_id, non_null(:id)
    field :listing_id, non_null(:id)
  end

  object :contact do
    field :id, :id
    field :name, :string
    field :email, :string
    field :phone, :string
    field :message, :string

    field :state, :string
    field :city, :string
    field :neighborhood, :string
  end

  object :price_request do
    field :id, :id
    field :name, :string
    field :email, :string
    field :area, :integer
    field :rooms, :integer
    field :suites, :integer
    field :type, :string
    field :maintenance_fee, :float
    field :bathrooms, :integer
    field :garage_spots, :integer
    field :is_covered, :boolean
    field :suggested_price, :float
    field :listing_price_rounded, :float
    field :listing_price_error_q90_min, :float
    field :listing_price_error_q90_max, :float
    field :listing_price_per_sqr_meter, :float
    field :listing_average_price_per_sqr_meter, :float

    field :address, :address, resolve: dataloader(Re.Addresses)
    field :user, :user, resolve: dataloader(Re.Accounts)
  end

  object :interest_type do
    field :id, :id
    field :name, :string
  end

  object :simulation do
    field :cem, :string
    field :cet, :string
  end

  input_object :simulation_request do
    field :mutuary, non_null(:string)
    field :birthday, non_null(:date)
    field :include_coparticipant, non_null(:boolean)
    field :net_income, non_null(:decimal)
    field :net_income_coparticipant, :decimal
    field :birthday_coparticipant, :date
    field :fundable_value, non_null(:decimal)
    field :term, non_null(:integer)
    field :amortization, :boolean
    field :annual_interest, :float
    field :home_equity_annual_interest, :float
    field :calculate_tr, :boolean
    field :evaluation_rate, :decimal
    field :itbi_value, :decimal
    field :listing_price, :decimal
    field :listing_type, :string
    field :product_type, :string
    field :sum, :boolean
    field :insurer, :string
  end

  object :interest_queries do
    @desc "Interest types"
    field :interest_types,
      type: list_of(:interest_type),
      resolve: &InterestsResolver.interest_types/2

    @desc "Request funding simulation"
    field :simulate, type: :simulation do
      arg :input, non_null(:simulation_request)

      resolve &InterestsResolver.simulate/2
    end
  end

  object :interest_mutations do
    @desc "Show interest in listing"
    field :interest_create, type: :interest do
      arg :input, non_null(:interest_input)

      resolve &InterestsResolver.create_interest/2
    end

    @desc "Request contact"
    field :request_contact, type: :contact do
      arg :name, :string
      arg :phone, :string
      arg :email, :string
      arg :message, :string

      resolve &InterestsResolver.request_contact/2
    end

    @desc "Request price suggestion"
    field :request_price_suggestion, type: :price_request do
      arg :name, :string
      arg :email, :string
      arg :area, non_null(:integer)
      arg :rooms, non_null(:integer)
      arg :bathrooms, non_null(:integer)
      arg :garage_spots, non_null(:integer)
      arg :suites, :integer
      arg :type, :string
      arg :maintenance_fee, :float
      arg :is_covered, non_null(:boolean)

      arg :address, non_null(:address_input)

      resolve &InterestsResolver.request_price_suggestion/2
    end

    @desc "Request notification when covered"
    field :notify_when_covered, type: :contact do
      arg :name, :string
      arg :phone, :string
      arg :email, :string
      arg :message, :string

      arg :state, non_null(:string)
      arg :city, non_null(:string)
      arg :neighborhood, non_null(:string)

      resolve &InterestsResolver.notify_when_covered/2
    end
  end

  object :interest_subscriptions do
    @desc "Subscribe to email change"
    field :interest_created, :interest do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "interest_created"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :interest_create,
        topic: fn _ ->
          "interest_created"
        end
    end

    @desc "Subscribe to email change"
    field :contact_requested, :contact do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "contact_requested"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :request_contact,
        topic: fn _ ->
          "contact_requested"
        end
    end

    @desc "Subscribe to price suggestion requests"
    field :price_suggestion_requested, :price_request do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "price_suggestion_requested"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :request_price_suggestion,
        topic: fn _ ->
          "price_suggestion_requested"
        end
    end

    @desc "Subscribe to price suggestion requests"
    field :notification_coverage_asked, :contact do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "notification_coverage_asked"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :notify_when_covered,
        topic: fn _ ->
          "notification_coverage_asked"
        end
    end
  end
end

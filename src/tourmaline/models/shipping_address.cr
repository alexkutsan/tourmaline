module Tourmaline::Model
  class ShippingAddress
    include JSON::Serializable

    getter country_code : String

    getter state : String

    getter city : String

    getter street_line1 : String

    getter street_line2 : String

    getter post_code : String
  end
end

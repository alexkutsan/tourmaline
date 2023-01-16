module Tourmaline::Model
  class Invoice
    include JSON::Serializable

    property title : String

    property description : String

    property start_parameter : String

    property currency : String

    property total_amount : Int32

    def initialize(@title, @description, @start_parameter, @currency, @total_amount)
    end
  end
end

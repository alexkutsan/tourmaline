module Tourmaline::Model
  class MenuButtonCommands
    include JSON::Serializable

    getter type : String

    def initialize(@type : String)
    end
  end
end

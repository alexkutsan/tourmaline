module Tourmaline::Model
  class ChatLocation
    include JSON::Serializable

    getter location : Location

    getter address : String
  end
end

module Tourmaline::Model
  class InputMediaPhoto
    include JSON::Serializable

    @type = "photo"

    property media : String | File

    property caption : String?

    property parse_mode : ParseMode?

    property caption_entities : Array(MessageEntity) = [] of MessageEntity

    def initialize(@media, @caption = nil, @parse_mode = nil, @caption_entities = [] of MessageEntity)
    end
  end
end

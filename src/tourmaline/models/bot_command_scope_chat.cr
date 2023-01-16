module Tourmaline::Model
  class BotCommandScopeChat
    include JSON::Serializable

    getter type : String = "chat"

    # Unique identifier for the target chat or username of the target supergroup
    # (in the format `@supergroupusername`)
    property chat_id : Int64 | String

    def initialize(chat : Chat | Int64 | String)
      @chat_id = chat.is_a?(Chat) ? chat.id : chat
    end
  end
end

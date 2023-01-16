module Tourmaline::Model
  class InlineQueryResultCachedAudio < InlineQueryResult
    getter type : String = "audio"

    getter id : String

    getter audio_file_id : String

    getter reply_markup : InlineKeyboardMarkup?

    getter input_message_content : InputMessageContent?

    def initialize(@id : String, @audio_file_id, @reply_markup = nil, @input_message_content = nil)
    end
  end
end

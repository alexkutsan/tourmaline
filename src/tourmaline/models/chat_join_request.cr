module Tourmaline::Model
  class ChatJoinRequest
    include JSON::Serializable

    getter chat : Chat

    getter from : User

    getter date : Int64

    getter bio : String?

    getter invite_link : ChatInviteLink?
  end
end

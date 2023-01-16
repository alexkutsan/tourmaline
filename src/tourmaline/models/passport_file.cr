module Tourmaline::Model
  class PassportFile
    include JSON::Serializable

    getter file_id : String

    getter file_unique_id : String

    getter file_size : Int64

    @[JSON::Field(converter: Time::EpochConverter)]
    getter file_date : Time?
  end
end

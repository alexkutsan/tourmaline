module Tourmaline::Model
  class EncryptedPassportElement
    include JSON::Serializable

    getter type : EncryptedPassportElement::Type

    getter data : String?

    getter phone_number : String?

    getter email : String?

    getter files : Array(PassportFile) = [] of Tourmaline::Model::PassportFile

    getter front_side : Array(PassportFile) = [] of Tourmaline::Model::PassportFile

    getter reverse_side : Array(PassportFile) = [] of Tourmaline::Model::PassportFile

    getter selfie : PassportFile?

    getter translation : Array(PassportFile) = [] of Tourmaline::Model::PassportFile

    getter hash : String

    enum Type
      PersonalDetails
      Passport
      DriverLicense
      IdentityCard
      InternalPassport
      Address
      UtilityBill
      BankStatement
      RentalAgreement
      PassportRegistration
      TemporaryRegistration
      PhoneNumber
      Email

      def to_json(json : JSON::Builder)
        json.string(to_s)
      end

      def self.from_json(pull : JSON::PullParser)
        parse(pull.read_string)
      end
    end
  end
end

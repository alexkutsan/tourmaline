require "halite"
require "mime/multipart"

require "./helpers"
require "./error"
require "./logger"
require "./context"
require "./container"
require "./chat_action"
require "./update_action"
require "./models/*"
require "./fiber"
require "./annotations"
require "./handlers/*"
require "./client/*"
require "./markup"
require "./query_result_builder"

module Tourmaline
  # The `Client` class is the base class for all Tourmaline based bots.
  # Extend this class to create your own bots, or create an
  # instance of `Client` and add commands and listenters to it.
  class Client
    include Logger
    include Handler::Annotator

    API_URL = "https://api.telegram.org/"

    DEFAULT_EXTENSIONS = {
      audio:      "mp3",
      photo:      "jpg",
      sticker:    "webp",
      video:      "mp4",
      animation:  "mp4",
      video_note: "mp4",
      voice:      "ogg",
    }

    # Gets the name of the Client at the time the Client was
    # started. Refreshing can be done by setting
    # `@bot_name` to `get_me.username.to_s`.
    getter bot_name : String { get_me.username.to_s }
    getter handlers : Hash(UpdateAction, Array(Handler))

    property endpoint_url : String

    # Create a new instance of `Tourmaline::Client`. It is
    # highly recommended to set `@api_key` at an environment
    # variable. `@logger` can be any logger that extends
    # Crystal's built in Logger.
    def initialize(
      @api_key : String,
      @updates_timeout : Int32? = nil,
      @allowed_updates : Array(String)? = nil
    )
      @endpoint_url = Path[API_URL, "bot" + @api_key].to_s
      @handlers = {} of UpdateAction => Array(Handler)
      register_annotated_methods

      Container.client = self
    end

    def add_handler(handler : Handler)
      handler.actions.each do |action|
        @handlers[action] ||= [] of Handler
        @handlers[action] << handler
      end
    end

    private def handle_update(update : Update)
      actions = Helpers.actions_from_update(update)
      actions.each do |action|
        trigger_handlers(action, update)
      end
    end

    def trigger_handlers(action : UpdateAction, update : Update)
      if handlers = @handlers[action]?
        handlers.each do |handler|
          handler.handle_update(self, update)
        end
      end
    end

    # Sends a json request to the Telegram Client API.
    private def request(method, params = {} of String => String)
      method_url = ::File.join(@endpoint_url, method)
      multipart = includes_media(params)

      if multipart
        config = build_form_data_config(params)
        response = Halite.request(**config, uri: method_url)
      else
        config = build_json_config(params)
        response = Halite.request(**config, uri: method_url)
      end

      result = JSON.parse(response.body)

      if res = result["result"]?
        res.to_json
      else
        handle_error(response.status_code, result["description"].as_s)
      end
    end

    # Parses the status code and returns the right error
    private def handle_error(code, message)
      case code
      when 401..403
        raise Error::Unauthorized.new(message)
      when 400
        raise Error::BadRequest.new(message)
      when 404
        raise Error::InvalidToken.new
      when 409
        raise Error::Conflict.new(message)
      when 413
        raise Error::NetworkError.new("File too large. Check telegram api limits https://core.telegram.org/bots/api#senddocument.")
      when 503
        raise Error::NetworkError.new("Bad gateway")
      else
        raise Error.new("#{message} (#{code})")
      end
    end

    private def object_or_id(object)
      if object.responds_to?(:id)
        return object.id
      end
      object
    end

    private def includes_media(params)
      params.values.any? do |val|
        case val
        when Array
          val.any? { |v| v.is_a?(::File | InputMedia) }
        when ::File, InputMedia
          true
        else
          false
        end
      end
    end

    private def build_json_config(payload)
      {
        verb:    "POST",
        headers: {"Content-Type" => "application/json", "Connection" => "keep-alive"},
        raw:     payload.to_h.compact.to_json, # TODO: Figure out why this is necessary
      }
    end

    private def build_form_data_config(payload)
      boundary = MIME::Multipart.generate_boundary
      formdata = MIME::Multipart.build(boundary) do |form|
        payload.each do |key, value|
          attach_form_value(form, key.to_s, value)
        end
      end

      {
        verb:    "POST",
        headers: {
          "Content-Type" => "multipart/form-data; boundary=#{boundary}",
          "Connection"   => "keep-alive",
        },
        raw: formdata,
      }
    end

    private def attach_form_value(form : MIME::Multipart::Builder, id : String, value)
      return unless value
      headers = HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}"}

      case value
      when Array
        # Likely an Array(InputMedia)
        items = value.map do |item|
          if item.is_a?(InputMedia)
            attach_form_media(form, item)
          end
          item
        end
        form.body_part(headers, items.to_json)
      when InputMedia
        attach_form_media(form, value)
        form.body_part(headers, value.to_json)
      when ::File
        filename = "#{id}.#{DEFAULT_EXTENSIONS[id]? || "dat"}"
        form.body_part(
          HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}; filename=#{filename}"},
          value
        )
      else
        form.body_part(headers, value.to_json)
      end
    end

    private def attach_form_media(form : MIME::Multipart::Builder, value : InputMedia)
      media = value.media
      thumb = value.responds_to?(:thumb) ? value.thumb : nil

      {media: media, thumb: thumb}.each do |key, item|
        item = check_open_local_file(item)
        if item.is_a?(::File)
          id = Random.new.random_bytes(16).hexstring
          filename = "#{id}.#{DEFAULT_EXTENSIONS[id]? || "dat"}"

          form.body_part(
            HTTP::Headers{"Content-Disposition" => "form-data; name=#{id}; filename=#{filename}"},
            item
          )

          if key == :media
            value.media = "attach://#{id}"
          elsif value.responds_to?(:thumb)
            value.thumb = "attach://#{id}"
          end
        end
      end
    end

    private def check_open_local_file(file)
      if file.is_a?(String)
        if ::File.file?(file)
          return ::File.open(file)
        end
      end
      file
    end

    # Parse mode for messages.
    enum ParseMode
      Normal
      Markdown
      MarkdownV2
      HTML
    end
  end
end

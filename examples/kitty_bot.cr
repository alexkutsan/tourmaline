require "../src/tourmaline"

class KittyBot < Tourmaline::Bot
  include Tourmaline

  REPLY_MARKUP = Markup.buttons([
    Markup.button("/kitty"),
    Markup.button("/kittygif"),
  ]).keyboard

  API_URL = "https://thecatapi.com/api/images/get"

  @[Command(["start", "help"])]
  def help_command(ctx)
    ctx.message.reply("😺 Use commands: /kitty, /kittygif and /about", reply_markup: REPLY_MARKUP)
  end

  @[Command("about")]
  def about_command(ctx)
    text = "😽 This bot is powered by Tourmaline, a Telegram bot library for Crystal. Visit https://github.com/watzon/tourmaline to check out the source code."
    ctx.message.reply(text)
  end

  @[Command(["kitty", "kittygif"])]
  def kitty_command(ctx)
    # The time hack is to get around Telegram's image cache
    api = API_URL + "?time=#{Time.utc}&format=src&type="

    case ctx.command
    when "kitty"
      ctx.message.chat.send_chat_action(:upload_photo)
      ctx.message.chat.send_photo(api + "jpg")
    when "kittygif"
      ctx.message.chat.send_chat_action(:upload_photo)
      ctx.message.chat.send_animation(api + "gif")
    end
  end
end

bot = KittyBot.new(ENV["API_KEY"])
bot.poll

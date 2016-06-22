require 'rubygems'
require 'json'
require 'net/http'
require 'net/https'
require 'uri'

load 'config/config-oauth.rb'
load 'lib/tls.rb'
load 'lib/blueprints.rb'
load 'lib/favorites.rb'
load 'lib/tweet.rb'
load 'lib/message.rb'
load 'lib/follow.rb'

class YamoBot

  def set_config(bool)
    $settings["local_keys2"] = bool
  end

  def input_keys

    open('auth.temp', 'w') { |f|
      puts "Enter Consumer Key"
      f << gets
      puts "Enter Consumer Secret"
      f << gets
      puts "Enter Access Token"
      f << gets
      puts "Enter Access Secret"
      f << gets
    }

  end

  def finalize_settings
    File.open("config/settings.json","w") do |f|
      f.write($settings.to_json)
    end
  end

  def auto name

    def selection input, usr_settings

      @output = "autobot.post_tweet('#{input}')"
      @output = "autobot.like_tweet('#{input}')"
      @output = "autobot.unlike_tweet('#{input}')"
      @output = "autobot.getList('#{input1},#{input2},#{input3}')"
      @output = "autobot.follow('#{input1},#{input2},#{input3}')"
      @output = "autobot.unfollow('#{input1},'#{input2}')"
      @output = "autobot.direct_message('#{input1},'#{input2},'#{input3}')"

    end
  end

end

new_bot = YamoBot.new

new_tweet = PostTweet.new
new_tweet.post_tweet("next test")

like_tweet = Like.new
like_tweet.like_tweet('input')

unlike_tweet = Unlike.new
unlike_tweet.unlike_tweet('input')

like_list = LikeList.new
like_list.getList(num,'user_id',scrn_nme)
follow_user = Follow.new
follow_user.follow(user_id, screen_name, bool)

dm_user = Message.new
dm_user.direct_message(user_id, screen_name, text)
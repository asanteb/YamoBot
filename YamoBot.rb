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

end

new_bot = YamoBot.new
new_bot.input_keys
new_tweet = PostTweet.new
new_tweet.post_tweet("next test")

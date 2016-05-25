
class Like #Likes/Favorites twitter post

  def like_tweet tweet_id #Requires twitter_id, this id number can be found on a url link of a specific tweet
    instructions = Blueprints.new
    api_url = instructions.getAPI_URL
    command_url = instructions.getLike_URL

    address = URI("#{api_url}#{command_url}")
    request = Net::HTTP::Post.new address.request_uri
    request.set_form_data id: tweet_id

    authReq = TLS.new
    authReq.connect_req(address, request)

    #@tweet = JSON.parse(response.body)
  end
end


class Unlike #Unlikes/Unfavorites twitter posts

  def unlike_tweet tweet_id
    instructions = Blueprints.new
    api_url = instructions.getAPI_URL
    command_url = instructions.getUnlike_URL

    address = URI("#{api_url}#{command_url}")
    request = Net::HTTP::Post.new address.request_uri
    request.set_form_data("id" => tweet_id)

    authReq = TLS.new
    authReq.connect_req(address, request)
  end

end


class LikeList #Gets a selected number of liked tweets form a particular user

  def getList num_of_tweets, user_id, screen_name #Choose between user id or screename, required number
    instructions = Blueprints.new
    api_url = instructions.getAPI_URL
    command_url = instructions.getLikeList_URL
    address = URI("#{api_url}#{command_url}")

      address = URI("#{address}?count=#{num_of_tweets}&screen_name=#{user_id}") if user_id
      address = URI("#{address}?count=#{num_of_tweets}&screen_name=#{screen_name}") if screen_name

    request = Net::HTTP::Get.new address.request_uri
    authReq = TLS.new
    response = authReq.connect_req(address, request)

    temp_tweets = JSON.parse(response.body) #creates a json object from response
    @tweets = JSON.pretty_generate(temp_tweets) #returns json format ready for printing
  end
end

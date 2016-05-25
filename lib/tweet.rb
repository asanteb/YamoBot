
class PostTweet

  def post_tweet str_body #Sometimes required formatting is required to make the tweet look nice

    instructions = Blueprints.new
    api_url = instructions.getAPI_URL
    command_url = instructions.getTweetPost_URL

    address = URI("#{api_url}#{command_url}")
    request = Net::HTTP::Post.new address.request_uri
    request.set_form_data status: str_body

    authReq = TLS.new
    authReq.connect_req address, request  # () Can be removed


   #@tweet = JSON.parse(response.body) // using this line will create a JSON object from the response
  end
end

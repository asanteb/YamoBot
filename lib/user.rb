class User

  def get_object (user_id, screen_name) #sends user info in twitter request object

    instructions = Blueprints.new
    api_url = instructions.getAPI_URL
    command_url = instructions.getUser

    address = URI("#{api_url}#{command_url}")
    address = URI("#{address}?screen_name=#{screen_name}") if screen_name
    address = URI("#{address}?user_id=#{user_id}") if user_id

    request = Net::HTTP::Get.new address.request_uri
    authReq = TLS.new
    @obj = authReq.connect_req address, request
  end

end


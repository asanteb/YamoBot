
class Follow #Follows user

  def follow(user_id, screen_name, bool) #Choose between user id or screename // bool to set notifications on/off
    instructions = Blueprints.new
    api_url = instructions.getAPI_URL
    command_url = instructions.getFollow_URL

    address = URI("#{api_url}#{command_url}")
    address = URI("#{address}?screen_name=#{screen_name}&follow=#{bool}") if screen_name
    address = URI("#{address}?user_id=#{user_id}&follow=#{bool}") if user_id

    request = Net::HTTP::Post.new address.request_uri
    authReq = TLS.new
    authReq.connect_req address, request
  end

  def check_if_following(target_screen_name, source_screen_name) #Checks relationship of followers
    instructions = Blueprints.new
    api_url = instructions.getAPI_URL
    command_url = instructions.getFollowerComparison_URL

    address = URI("#{api_url}#{command_url}")
    address = URI("#{address}?source_screen_name=#{source_screen_name}&target_screen_name=#{target_screen_name}")

    request = Net::HTTP::Get.new address.request_uri
    authReq = TLS.new
    authReq.connect_req address, request
  end
end

class Unfollow #UnFollows user

  def unfollow(user_id, screen_name) #Choose between user id or screename
    instructions = Blueprints.new
    api_url = instructions.getAPI_URL
    command_url = instructions.getUnfollow_URL

    address = URI("#{api_url}#{command_url}")
    address = URI("#{address}?screen_name=#{screen_name}") if screen_name
    address = URI("#{address}?user_id=#{user_id}") if user_id

    request = Net::HTTP::Post.new address.request_uri
    authReq = TLS.new
    authReq.connect_req address, request
  end
end



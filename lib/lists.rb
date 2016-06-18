
class List

  def getList screen_name
    instructions = Blueprints.new
    api_url = instructions.getAPI_URL
    command_url = instructions.getLists_URL

    address = URI("#{api_url}#{command_url}?screen_name=#{screen_name}")

    request = Net::HTTP::Get.new address.request_uri
    authReq = TLS.new

    authReq.connect_req address, request

  end

  def getList_members slug, owner_screen_name, count
  instructions = Blueprints.new
  api_url = instructions.getAPI_URL
  command_url = instructions.getListMembers_URL

  address = URI("#{api_url}#{command_url}?slug=#{slug}&owner_screen_name=#{owner_screen_name}&count=#{count}")

  request = Net::HTTP::Get.new address.request_uri
  authReq = TLS.new

  authReq.connect_req address, request

  end
end

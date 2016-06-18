#This class is dedicated to returning a small lists of calls from the Twitter REST API
#The API calls can be be found here: https://dev.twitter.com/rest/public

class Blueprints

  def getAPI_URL
    @url = "https://api.twitter.com"
  end

  def getTweetPost_URL
    @url = "/1.1/statuses/update.json"
  end

  def getLike_URL
    @url = "/1.1/favorites/create.json"
  end

  def getUnlike_URL
    @url = "/1.1/favorites/destroy.json"
  end

  def getLikeList_URL
    @url = "/1.1/favorites/list.json"
  end

  def getFollow_URL
    @url = "/1.1/friendships/create.json"
  end

  def getUnfollow_URL
    @url = "/1.1/friendships/destroy.json"
  end

  def getFollowerComparison_URL
    @url = "/1.1/friendships/show.json"
  end

  def getMessage_URL
    @url = "/1.1/direct_messages/new.json"
  end

  def getLists_URL
    @url = "/1.1/lists/ownerships.json"
  end

  def getListMembers_URL
    @url = "/1.1/lists/members.json"
  end

end
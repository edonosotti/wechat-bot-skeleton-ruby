# Define an interface for possible future implementations of database managers.
module IDatabaseManager

  def initialize(_database_url)
    raise "Not implemented"
  end

  def store_message(_message)
    raise "Not implemented"
  end

  def fetch_message
    raise "Not implemented"
  end

end

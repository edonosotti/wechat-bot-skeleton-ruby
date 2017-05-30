# Define an interface for possible future implementations of database managers.
module IDatabaseManager

  def initialize(database_url)
    raise "Not implemented"
  end

  def store_message(message)
    raise "Not implemented"
  end

  def fetch_message
    raise "Not implemented"
  end

end

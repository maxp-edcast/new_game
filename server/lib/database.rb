 # DataMapper::Logger.new($stdout, :debug)
 DataMapper.setup(:default, "postgres://max@localhost")

class Post
  include DataMapper::Resource

  property :id,         Serial    # An auto-increment integer key
  property :title,      String    # A varchar type string, for short strings
  property :body,       Text      # A text block, for longer string data.
  property :created_at, DateTime  # A DateTime, for any date you might like.
end

DataMapper.finalize
DataMapper.auto_upgrade!

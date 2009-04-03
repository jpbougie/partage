class Share
  include DataMapper::Resource
  
  property :id, Serial
  
  property :shareable_id, Integer
  property :shareable_type, String
  
  property :email_sent, Boolean, :default => false
  property :key, String
  
  belongs_to :friend
  
  before :save, :generate_key
  
  def self.share(object, *friends)
    for friend in friends
      Share.create(:shareable_id => object.id, :shareable_type => object.class.to_s, :friend => friend)
    end
  end
  
  protected
  
  def generate_key
    # taken from merb's session
    # see merb-core/lib/merb-core/dispatch/session.rb#L77
    values = [
      rand(0x0010000),
      rand(0x0010000),
      rand(0x0010000),
      rand(0x0010000),
      rand(0x0010000),
      rand(0x1000000),
      rand(0x1000000),
    ]
    self.key = "%04x%04x%04x%04x%04x%06x%06x" % values
  end
end

class Friend
  include DataMapper::Resource
  
  property :id, Serial
  property :email, String

  has n, :shares
  has n, :shared_files, :through => :shares, Share.properties[:shareable_type] => 'SharedFile', :remote_name => :friend
  has n, :file_sets, :through => :shares, Share.properties[:shareable_type] => 'FileSet', :remote_name => :friend

end
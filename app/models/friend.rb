class Share
  include DataMapper::Resource
  
  property :id, Serial
  
  property :shareable_id, Integer
  property :shareable_type, String
  
  property :email_sent, Boolean, :default => false
  
  belongs_to :friend
  
  def self.share(object, *friends)
    for friend in friends
      Share.create(:shareable_id => object.id, :shareable_type => object.class.to_s, :friend => friend)
    end
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
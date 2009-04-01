class Friend
  include DataMapper::Resource
  
  property :id, Serial
  property :email, String

  has n, :shares
  has n, :shared_files, :through => :shares, :child_key => [:shareable_id], :shareable_type => 'SharedFile'
  has n, :file_sets, :through => :shares, :child_key => [:shareable_id], :shareable_type => 'FileSet'

end

class Share
  include DataMapper::Resource
  
  property :shareable_id, Integer
  property :shareable_type, String
  
  property :email_sent, Boolean
  
  belongs_to :friend
end
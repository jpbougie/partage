class SharedFile
  include DataMapper::Resource
  
  property :id, Serial
  property :filename, String
  property :content_type, String
  property :size, Integer
  property :hash, String
  
  property :temp, Boolean, :default => true
  
  belongs_to :file_set
  
  #has n, :shares, :class_name => 'FileShare', :child_key => [:shared_file_id]
  #has n, :friends, :through => :shares

  def file_path
    Merb::Config[:upload_dir] / self.hash[0..1] / (self.hash[2..-1] + '-' + self.size.to_s )
  end
  
  def media_type
    MIME::Types[self.content_type][0].media_type
  end
  
  def shares
    FileShare.all(:shared_file_id => self.id)
  end
  
  def friends
    self.shares.friend
  end
  
  # Returns the effective shares for a file.
  # By default, a file has the same share as its set
  # If specific shares have been written, they will completely override the set shares
  def effective_shares
    return self.shares unless self.shares.blank?
    
    if self.file_set
      self.file_set.shares
    end
  end
  
  def authorized_with_key? passkey
    !self.effective_shares.first(:passkey => passkey).blank?
  end
  
  def authorized_user? user
    return true if user == self.file_set.user # a user always has access to its own stuff
    
    !self.effective_shares.friend.first(:email => user.email)
  end
end

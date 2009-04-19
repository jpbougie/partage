class Share
  include DataMapper::Resource
  
  property :id, Serial
  property :email_sent, Boolean, :default => false
  property :passkey, String
  
  belongs_to :friend
  
  property :shareable_type, Discriminator
  
  
  before :save, :generate_key
  
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
    self.passkey = "%04x%04x%04x%04x%04x%06x%06x" % values
  end
end

class SetShare < Share
  belongs_to :file_set
end

class FileShare < Share
  belongs_to :shared_file
end

class Friend
  include DataMapper::Resource
  
  property :id, Serial
  property :email, String
  
  belongs_to :user

  has n, :shares
  has n, :set_shares
  has n, :file_shares
  
  has n, :file_sets, :through => :set_shares
  has n, :shared_files, :through => :file_shares
  
  def self.get_or_create(emails, params = {})
    existing = self.all(:email.in => emails)
    to_create = emails - existing.collect {|f| f.email }
    
    existing + to_create.collect{|e| self.create(params.update(:email => e))}
  end

end
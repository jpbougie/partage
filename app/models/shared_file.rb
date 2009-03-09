class SharedFile
  include DataMapper::Resource
  
  property :id, Serial
  property :filename, String, :nullable => false
  property :mimetype, String, :nullable => false
  property :hash, String, :nullable => false, :format => %r{[\da-f]{40}}
  
  belongs_to :user


end

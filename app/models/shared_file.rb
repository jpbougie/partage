class SharedFile
  include DataMapper::Resource
  
  property :id, Serial
  property :filename, String
  property :content_type, String
  property :size, Integer
  property :hash, String
  
  property :temp, Boolean, :default => true
  
  belongs_to :file_set
  
  has n, :shares, :class_name => 'FileShare'
  has n, :friends, :through => :shares

  def file_path
    Merb::Config[:upload_dir] / self.hash[0..1] / (self.hash[2..-1] + '-' + self.size.to_s )
  end
  
  def media_type
    MIME::Types[self.content_type][0].media_type
  end
end

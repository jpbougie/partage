class SharedFile
  include DataMapper::Resource
  
  property :id, Serial
  property :filename, String
  property :content_type, String
  property :size, Integer
  property :hash, String
  
  property :temp, Boolean, :default => true
  
  belongs_to :file_set
  has n, :shares, :child_key => [:shareable_id], :shareable_type => self.to_s
  has n, :friends, :through => :shares, :child_key => [:shareable_id], Share.properties[:shareable_type] => self.to_s, :mutable => true

  def file_path
    Merb::Config[:upload_dir] / self.hash[0..1] / (self.hash[2..-1] + '-' + self.size.to_s )
  end
end

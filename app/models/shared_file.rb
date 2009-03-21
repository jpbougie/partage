class SharedFile
  include DataMapper::Resource
  
  property :id, Serial
  property :filename, String
  property :content_type, String
  property :size, Integer
  property :hash, String
  
  belongs_to :file_set

  def file_path
    Merb::Config[:upload_dir] / self.hash[0..1] / (self.hash[2..-1] + '-' + self.size.to_s )
  end
end

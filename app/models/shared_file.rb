class SharedFile
  include DataMapper::Resource
  
  property :id, Serial
  property :filename, String, :nullable => false
  property :content_type, String
  property :size, Integer
  property :hash, String, :nullable => false, :format => %r{[\da-f]{40}}
  
  belongs_to :user

  def file_path
    Merb::Config[:upload_dir] / self.hash[0..1] / self.hash[2..-1]
  end
end

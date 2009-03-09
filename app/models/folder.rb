class Folder
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  
  has n, :shared_files

end

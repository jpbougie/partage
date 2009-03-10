class Folder
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :nullable => false
  property :parent_id, Integer
  
  is :tree, :order => :name
  
  has 1, :user
  has n, :shared_files
  
  def /(subfolder)
    self.children.first(:name => subfolder)
  end

end

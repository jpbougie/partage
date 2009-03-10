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

  def full_path
    if self.parent
      parent_path = self.parent.full_path
      parent_path + (parent_path[-1,1] != '/' ? '/' : '') + self.name
    else
      self.name
    end
  end

end

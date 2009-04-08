class FileSet
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :nullable => false
  property :slug, String

  belongs_to :user
  has n, :shared_files
  
  has n, :shares, :class_name => 'SetShare'
  has n, :friends, :through => :shares
  
  before :save, :slugify
  
  def default?
    self.name == '_default'
  end
  
  protected
  
  def slugify
    self.slug = self.name.downcase.gsub(/[@.]/, '-').gsub(/[^0-9a-z_ -]/i, '').gsub(/\s+/, '-')
  end

end

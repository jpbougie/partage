class FileSet
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :nullable => false
  property :slug, String

  belongs_to :user
  has n, :shared_files
  
  before :save, :slugify
  
  protected
  
  def slugify
    self.slug = self.name.downcase.gsub(/[@.]/, '-').gsub(/[^0-9a-z_ -]/i, '').gsub(/\s+/, '-')
  end

end

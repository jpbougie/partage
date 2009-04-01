class FileSet
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :nullable => false
  property :slug, String

  belongs_to :user
  has n, :shared_files
  
  has n, :shares, :child_key => [:shareable_id], :shareable_type => self.to_s
  has n, :friends, :through => :shares, :child_key => [:shareable_id], Share.properties[:shareable_type] => self.to_s
  
  before :save, :slugify
  
  def default?
    self.name == '_default'
  end
  
  protected
  
  def slugify
    self.slug = self.name.downcase.gsub(/[@.]/, '-').gsub(/[^0-9a-z_ -]/i, '').gsub(/\s+/, '-')
  end

end

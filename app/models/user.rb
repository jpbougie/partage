# This is a default user class used to activate merb-auth.  Feel free to change from a User to 
# Some other class, or to remove it altogether.  If removed, merb-auth may not work by default.
#
# Don't forget that by default the salted_user mixin is used from merb-more
# You'll need to setup your db as per the salted_user mixin, and you'll need
# To use :password, and :password_confirmation when creating a user
#
# see merb/merb-auth/setup.rb to see how to disable the salted_user mixin
# 
# You will need to setup your database and create a user.
class User
  include DataMapper::Resource
  
  property :id,     Serial
  property :email,  String
  property :slug,   String
  
  has n, :file_sets
    
  before :save, :slugify
  
  def default_file_set
    default = self.file_sets.first(:name => '_default')
    
    unless default
      default = FileSet.new
      default.name = '_default'
      default.user = self
      default.save
    end
    
    default
  end
  
  protected
  
  def slugify
    self.slug = self.email.downcase.gsub(/[@.]/, '-').gsub(/[^0-9a-z_ -]/i, '').gsub(/\s+/, '-')
  end

end

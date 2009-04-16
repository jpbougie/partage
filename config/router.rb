# Merb::Router is the request routing mapper for the merb framework.
#
# You can route a specific URL to a controller / action pair:
#
#   match("/contact").
#     to(:controller => "info", :action => "contact")
#
# You can define placeholder parts of the url with the :symbol notation. These
# placeholders will be available in the params hash of your controllers. For example:
#
#   match("/books/:book_id/:action").
#     to(:controller => "books")
#   
# Or, use placeholders in the "to" results for more complicated routing, e.g.:
#
#   match("/admin/:module/:controller/:action/:id").
#     to(:controller => ":module/:controller")
#
# You can specify conditions on the placeholder by passing a hash as the second
# argument of "match"
#
#   match("/registration/:course_name", :course_name => /^[a-z]{3,5}-\d{5}$/).
#     to(:controller => "registration")
#
# You can also use regular expressions, deferred routes, and many other options.
# See merb/specs/merb/router.rb for a fairly complete usage sample.

Merb.logger.info("Compiling routes...")
Merb::Router.prepare do
  
  authenticate do
    resources :users, :identify => :slug, :key => :user_slug do
      resources :file_sets, :identify => :slug, :key => :file_set_slug do
        resources :shared_files do
        end
      end
    end
  end

  # quasi-public facing views, access to stuff that has been shared
  match("/preview/:id").to(:controller => :shared_files, :action => "preview").name("preview")
  match("/thumbnail/:id").to(:controller => :shared_files, :action => "thumbnail").name("thumbnail")
  match("/download/:id").to(:controller => :shared_files, :action => "download").name("download")
  match("/view/:id").to(:controller => :shared_files, :action => "view").name("view")
  match("/view_set/:id").to(:controller => :file_sets, :action => "view").name("view_set")
  match("/archive/:id").to(:controller => :file_sets, :action => "archive").name("archive")
  
  match("/register").to(:controller => :users, :action => "new").name(:register)
  match("/").to(:controller => :main, :action => "index").name(:index)
  match("/upload").to(:controller => :shared_files, :action => "upload").fixatable.name("upload")

  
  # Adds the required routes for merb-auth using the password slice
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")

  # This is the default route for /:controller/:action/:id
  # This is fine for most cases.  If you're heavily using resource-based
  # routes, you may want to comment/remove this line to prevent
  # clients from calling your create or destroy actions with a GET
  #default_routes
  
  # Change this for your home page to be available at /
  # match('/').to(:controller => 'whatever', :action =>'index')
end
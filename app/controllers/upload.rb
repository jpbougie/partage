require 'digest/sha1'

class Upload < Application
  
  provides :json
  
  def index
    redirect(url(:dashboard, :user => session.user))
  end
  
  def dashboard
    redirect(request.path + "/tree")
  end
  
  def tree(user, pth)
    if pth == '/'
      @folder = session.user.folder
    else
      @folder = pth.split("/").delete_if {|folder| folder.blank? }.inject(session.user.folder) {|acc, folder| acc / folder or raise NotFound}
    end
    
    display @folder
  end
  
  def create(user)
    
    uploaded = params[:file]
    hash = Digest::Sha1.new.file(uploaded[:tempfile]).hexdigest
    @shared_file = SharedFile.create( :filename => uploaded[:filename],
                                      :content_type => uploaded[:content_type],
                                      :size => uploaded[:size],
                                      :user => session.user,
                                      :hash => hash
          )

    File.move(uploaded[:tempfile].path, @shared_file.file_path)
    
    display @shared_file
  end
  
end

require 'digest/sha1'

class Upload < Application
  
  provides :json
  
  def index
    redirect(url(:dashboard, :user => session.user))
  end
  
  def dashboard(user)
    @folder = session.user.folder
    display @folder
  end
  
  def tree(user, pth)
    if pth == '/'
      @folder = session.user.folder
    else
      @folder = pth.split.delete_if {|folder| folder.blank? }.inject {|acc, folder| acc / folder}
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

require 'digest/sha1'

class Upload < Application
  
  provides :json
  
  def index
    @shared_files = session.user.shared_files
    display @shared_files
  end
  
  def upload
    
    uploaded = params[:file]
    hash = Digest::Sha1.new.file(uploaded[:tempfile]).hexdigest
    @shared_file = SharedFile.create( :filename => uploaded[:filename],
                                      :content_type => uploaded[:content_type],
                                      :size => uploaded[:size],
                                      :user => session.user
                                      :hash => hash
          )

    File.move(uploaded[:tempfile].path, @shared_file.file_path)
    
    display @shared_file
  end
  
end

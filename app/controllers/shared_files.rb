class SharedFiles < Application
  # provides :xml, :yaml, :js
  provides :json, :xml
  
  before :ensure_shared, :only => [:download, :view, :preview, :thumbnail]

  def index
    @shared_files = SharedFile.all
    display @shared_files
  end

  def show(id)
    @shared_file = SharedFile.get(id)
    raise NotFound unless @shared_file
    display @shared_file
  end

  def new(user_slug, file_set_slug)
    @user = session.user
    raise NotAuthorized unless @user.slug == user_slug
    @file_set = @user.file_sets.first(:slug => file_set_slug)
    raise NotFound unless @file_set
    only_provides :html
    @shared_file = SharedFile.new
    
    display @shared_file
  end

  def edit(id)
    only_provides :html
    @shared_file = SharedFile.get(id)
    raise NotFound unless @shared_file
    display @shared_file
  end

  def create
    @user = session.user
    ids = params[:shared_files].split(',')
    
    friends = params[:shares].split(/[,\n ]/).map {|sh| sh.strip }.reject{|sh| sh.blank? }.map do |share|
      Friend.first(:email => share, :user => @user) or Friend.create(:email => share, :user => @user)
    end
    
    case params[:set_action]
      when 'files'
        set = @user.default_file_set
      when 'existing_set'
        set = @user.file_sets.get(params[:file_set])
      when 'new_set'
        set = FileSet.create(:name => params[:set_name])
        @user.file_sets << set
        friends.each do |friend| 
          sh = SetShare.create(:file_set => set, :friend => friend, :email_sent => true)
          run_later do
            send_mail(ShareMailer, :new_share, {
              :from => "test@jpbougie.net", 
              :to => friend.email,
              :subject => "New shared set from " + session.user.email
            }, {
              :type => "set",
              :name => params[:set_name],
              :email => session.user.email,
              :url => url(:view_set, set.key, { :key => sh.passkey }) })
          end
        end
        set.save
    end
    
    for shared_file in SharedFile.all(:id => ids)
      shared_file.temp = false
      if params[:set_action] == 'files'
        friends.each {|friend| shared_file.shares.create(:friend => friend) }
      end
      set.shared_files << shared_file
      
      shared_file.save
    end
    
    @user.save
    set.save
    
    redirect resource(@user), :message => {:notice => "The files were successfully shared"}
  end

  def update(id, shared_file)
    @shared_file = SharedFile.get(id)
    raise NotFound unless @shared_file
    if @shared_file.update_attributes(shared_file)
       redirect resource(@shared_file)
    else
      display @shared_file, :edit
    end
  end

  def destroy(id)
    @shared_file = SharedFile.get(id)
    raise NotFound unless @shared_file
    if @shared_file.destroy
      redirect resource(:shared_files)
    else
      raise InternalServerError
    end
  end
  
  def upload
    require 'digest/sha1'
    
    @user = session.user
    @file_set = @user.file_sets.get(params[:file_set])
    @file_set ||= @user.default_file_set
    
    fl = params[:Filedata]
    @shared_file = SharedFile.new(:filename => fl[:filename],
                                  :content_type => MIME::Types.of(fl[:filename])[0].content_type,
                                  :size => fl[:size],
                                  :hash => Digest::SHA1.new.file(fl[:tempfile].path).hexdigest,
                                  :file_set => @file_set)
    File.move(fl[:tempfile].path, @shared_file.file_path)
    
    if @shared_file.save
      if @shared_file.media_type == 'image' then
        run_later do
          img = Magick::Image.read(@shared_file.file_path).first
          thumbnail = img.thumbnail(80, ((80.0 / img.columns) * img.rows).ceil)
          thumbnail.write(@shared_file.file_path + '-80x80')
        end
      end
      @shared_file.to_json
    else
      message[:error] = "SharedFile failed to be created"
      render :new
    end
  end
  
  def download(id)
    @shared_file = SharedFile.get(id)
    raise NotFound unless @shared_file
    
    send_file @shared_file.file_path, :filename => @shared_file.filename, :type => @shared_file.content_type
  end

  def preview(id)
    @shared_file = SharedFile.get(id)
    raise NotFound unless @shared_file
    
    send_file @shared_file.file_path, :disposition => 'inline', :filename => @shared_file.filename, :type => @shared_file.content_type
  end
  
  def thumbnail(id)
    @shared_file = SharedFile.get(id)
    raise NotFound unless @shared_file
    
    send_file @shared_file.file_path + '-80x80', :disposition => 'inline', :filename => @shared_file.filename, :type => @shared_file.content_type
  end
  
  def view(id)
    @shared_file = SharedFile.get(id)
    raise NotFound unless @shared_file
    
    display @shared_file
  end
  
  protected
  
  def ensure_shared
    shf = SharedFile.get(params[:id])
    if params[:key]
      raise Unauthorized unless shf.authorized_with_key? params[:key]
    else
      raise Unauthorized unless (session.authenticated? and shf.authorized_user? session.user)
    end
  end

end # SharedFiles

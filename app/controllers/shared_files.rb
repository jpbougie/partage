class SharedFiles < Application
  # provides :xml, :yaml, :js
  provides :json, :xml
  
  before :has_access, :only => [:view, :preview, :download]

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
      Friend.first(:email => share) or Friend.create(:email => share)
    end
    
    case params[:set_action]
      when 'files'
        set = @user.default_file_set
      when 'existing_set'
        set = @user.file_sets.get(params[:file_set])
      when 'new_set'
        set = FileSet.create(:name => params[:set_name])
        @user.file_sets << set
        friends.each {|friend| set.shares.create(:friend => friend)}
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
    raise NotFound unless @file_set
    
    fl = params[:Filedata]
    @shared_file = SharedFile.new(:filename => fl[:filename],
                                  :content_type => MIME::Types.of(fl[:filename])[0].content_type,
                                  :size => fl[:size],
                                  :hash => Digest::SHA1.new.file(fl[:tempfile].path).hexdigest,
                                  :file_set => @file_set)
    File.move(fl[:tempfile].path, @shared_file.file_path)
    
    if @shared_file.save
      @shared_file.to_json
    else
      message[:error] = "SharedFile failed to be created"
      render :new
    end
  end
  
  def download(user_slug, file_set_slug, id)
    @user = User.first(:slug => user_slug)
    raise NotFound unless @user
    @file_set = @user.file_sets.first(:slug => file_set_slug)
    raise NotFound unless @file_set
    @shared_file = @file_set.shared_files.first(:id => id)
    raise NotFound unless @shared_file
    
    send_file @shared_file.file_path, :filename => @shared_file.filename, :type => @shared_file.content_type
  end

  def preview(user_slug, file_set_slug, id)
    @user = User.first(:slug => user_slug)
    @file_set = @user.file_sets.first(:slug => file_set_slug)
    raise NotFound unless @file_set
    @shared_file = @file_set.shared_files.first(:id => id)
    raise NotFound unless @shared_file
    
    send_file @shared_file.file_path, :disposition => 'inline', :filename => @shared_file.filename, :type => @shared_file.content_type
  end
  
  def view
    @shared_file = SharedFile.get(id)
    raise NotFound unless @shared_file
    display @shared_file
  end
  
  private
  
  def has_access
    shf = SharedFile.get(params[:id])
    if params[:key]
      raise Unauthorized unless shf.authorized_with_key? params[:key]
    else
      raise Unauthorized unless (session.authenticated? and shf.authorized_user? session.user)
    end
  end

end # SharedFiles

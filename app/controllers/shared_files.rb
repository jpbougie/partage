class SharedFiles < Application
  # provides :xml, :yaml, :js

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
    @user = User.first(:slug => user_slug)
    raise NotFound unless @user
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

  def create(shared_file)
    @shared_file = SharedFile.new(shared_file)
    if @shared_file.save
      redirect resource(@shared_file), :message => {:notice => "SharedFile was successfully created"}
    else
      message[:error] = "SharedFile failed to be created"
      render :new
    end
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
    
    @user = User.get(session[:user])
    raise NotFound unless @user
    @file_set = @user.file_sets.get(params[:file_set])
    raise NotFound unless @file_set
    
    fl = params[:Filedata]
    @shared_file = SharedFile.new(:filename => fl[:filename],
                                  :content_type => fl[:content_type],
                                  :size => fl[:size],
                                  :hash => Digest::SHA1.new.file(fl[:tempfile].path).hexdigest,
                                  :file_set => @file_set)
    File.move(fl[:tempfile].path, @shared_file.file_path)
    
    if @shared_file.save
      "ok"
    else
      message[:error] = "SharedFile failed to be created"
      render :new
    end
  end

end # SharedFiles

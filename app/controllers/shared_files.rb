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

  def new
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
    @shared_file = SharedFile.new(:filename => params[:file][:file_name],
                                  :content_type => params[:file][:content_type],
                                  :size => params[:file][:size],
                                  :hash => Digest::SHA1.new.file(params[:file][:tempfile]).hexdigest)
    File.move(params[:file][:tempfile], @shared_file.file_path)
    
    if @shared_file.save
      redirect resource(@shared_file), :message => {:notice => "SharedFile was successfully created"}
    else
      message[:error] = "SharedFile failed to be created"
      render :new
    end
  end

end # SharedFiles

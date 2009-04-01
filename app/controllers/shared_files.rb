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
    @user = User.get(session[:user])
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

  def create
    @user = User.get(session[:user])
    ids = params[:uploaded_files].split(',')
    
    case params[:set_action]
      when 'files'
        set = @user.default_file_set
      when 'existing_set'
        set = @user.file_sets.get(params[:file_set])
      when 'new_set'
        set = Set.create(:name => params[:set_name])
        @user.file_sets << set
        set.save
    end
    
    shares = param[:shares].split(/,\n /).map {|sh| sh.trim }.reject{|sh| sh.blank? }.map do |share|
      Friend.first(:email => share) or Friend.create(:email => share)
    end
    
    for shared_file in SharedFile.all(:id => ids)
      shared_file.temp = false
      set.shared_files << shared_file
      
      shared_file.save
    end
    
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
      @shared_file.to_json
    else
      message[:error] = "SharedFile failed to be created"
      render :new
    end
  end

end # SharedFiles

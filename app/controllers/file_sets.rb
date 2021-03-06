class FileSets < Application
  # provides :xml, :yaml, :js
  provides :json

  before :ensure_shared, :only => :archive

  def index(user_slug)
    @user = User.first(:slug => user_slug)
    raise NotFound unless @user
    @file_sets = @user.file_sets.all
    display @file_sets
  end

  def show(user_slug, file_set_slug)
    @user = User.first(:slug => user_slug)
    raise NotFound unless @user
    @file_set = @user.file_sets.first(:slug => file_set_slug)
    raise NotFound unless @file_set
    display @file_set
  end

  def new
    only_provides :html
    @file_set = FileSet.new
    display @file_set
  end

  def edit(user_slug, file_set_slug)
    only_provides :html
    @user = User.first(:slug => user_slug)
    raise NotFound unless @user
    @file_set = @user.file_sets.first(:slug => slug)
    raise NotFound unless @file_set
    display @file_set
  end

  def create
    @user = session.user
    @file_set = FileSet.create(:name => params[:set], :user => @user)
    emails = params[:friends].split(",")
    
    
    friends = Friend.get_or_create(emails, :user => @user)
    
    friends.each do |friend|
      sh = SetShare.create(:file_set => @file_set, :friend => friend, :email_sent => true)
      run_later do
        send_mail(ShareMailer, :new_share, {
          :from => "test@jpbougie.net", 
          :to => friend.email,
          :subject => "New shared set from " + @user.email
        }, {
          :type => "set",
          :name => @file_set.name,
          :email => @user.email,
          :url => url(:view_set, @file_set.key, { :key => sh.passkey }) })
      end
      
      params[:files].split(",").each do |fid|
        file = SharedFile.get(fid)
        file.file_set = @file_set
        file.temp = false
        file.save
      end
    end
    
    @file_set.to_json
    
  end

  def update(user_slug, file_set_slug, set)
    @user = User.first(:slug => user_slug)
    raise NotFound unless @user
    @file_set = @user.file_sets.first(:slug => slug)
    raise NotFound unless @file_set
    if @file_set.update_attributes(set)
       redirect resource(@file_set)
    else
      display @file_set, :edit
    end
  end

  def destroy(user_slug, file_set_slug)
    @user = User.first(:slug => user_slug)
    raise NotFound unless @user
    @file_set = @user.file_sets.first(:slug => slug)
    raise NotFound unless @file_set
    if @file_set.destroy
      redirect resource(:sets)
    else
      raise InternalServerError
    end
  end
  
  def view(id)
    @file_set = FileSet.get(id)
    raise NotFound unless @file_set
    
    display @file_set
  end
  
  def archive(id)
    @file_set = FileSet.get(id)
    raise NotFound unless @file_set
    
    archive_name = "#{@file_set.user.key}-#{@file_set.slug}.zip"
    archive_path = "/tmp/" + archive_name
    
    unless File.exists? archive_path
      Zip::ZipFile.open(archive_path, Zip::ZipFile::CREATE) do |zipfile|
        zipfile.mkdir(@file_set.slug)
        @file_set.shared_files.each do |shf|
          zipfile.add(@file_set.slug + '/' + shf.filename, shf.file_path)
        end
      end
    end
    
    send_file archive_path, :filename => archive_name, :type => 'application/zip'
  end
  
  protected
  
  def ensure_shared
    fs = FileSet.get(params[:id])
    if params[:key]
      raise Unauthorized unless fs.authorized_with_key? params[:key]
    else
      raise Unauthorized unless (session.authenticated? and fs.authorized_user? session.user)
    end
  end

end # FileSets

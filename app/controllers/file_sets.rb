class FileSets < Application
  # provides :xml, :yaml, :js

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

  def create(user_slug, set)
    @user = User.first(:slug => user_slug)
    raise NotFound unless @user
    @file_set = FileSet.new(set)
    if @file_set.save
      redirect resource(@file_set), :message => {:notice => "FileSet was successfully created"}
    else
      message[:error] = "FileSet failed to be created"
      render :new
    end
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

end # FileSets

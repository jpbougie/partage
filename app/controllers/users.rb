class Users < Application
  # provsluges :xml, :yaml, :js

  def index
    @users = User.all
    display @users
  end

  def show(user_slug)
    @user = User.first(:slug => user_slug)
    raise NotFound unless @user
    display @user
  end

  def new
    only_provides :html
    @user = User.new
    display @user
  end

  def edit(user_slug)
    only_provides :html
    @user = User.first(:slug => user_slug)
    raise NotFound unless @user
    display @user
  end

  def create(user)
    @user = User.new(user)
    if @user.save
      redirect resource(@user), :message => {:notice => "User was successfully created"}
    else
      message[:error] = "User failed to be created"
      render :new
    end
  end

  def update(user_slug, user)
    @user = User.first(:slug => user_slug)
    raise NotFound unless @user
    if @user.update_attributes(user)
       redirect resource(@user)
    else
      display @user, :edit
    end
  end

  def destroy(user_slug)
    @user = User.first(:slug => user_slug)
    raise NotFound unless @user
    if @user.destroy
      redirect resource(:users)
    else
      raise InternalServerError
    end
  end

end # Users

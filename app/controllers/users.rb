class Users < Application
  # provides :xml, :yaml, :js

  before :ensure_authenticated, :only => ["show", "edit", "update", "detroy"]
  before :ensure_authorized, :only => ["show", "edit", "update", "detroy"]

  def index
    redirect url(:index)
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
      session[:user] = @user.id
      redirect resource(@user), :message => {:notice => "Your account was successfully created"}
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
  
  protected
  
  def ensure_authorized
    raise Unauthorized unless params[:user_slug] == session.user.slug
  end
end # Users

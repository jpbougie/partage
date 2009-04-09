class Main < Application
  def index
    if session.authenticated?
      redirect resource(session.user)
    else
      render
    end
  end
end
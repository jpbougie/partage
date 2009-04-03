class Application < Merb::Controller
  def index
    if session.authenticated?
      redirect resource(session.user)
    else
      render
    end
  end
end
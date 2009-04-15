class ShareMailer < Merb::MailController

  def new_share
    # use params[] passed to this controller to get data
    # read more at http://wiki.merbivore.com/pages/mailers
    render_mail
  end
  
end

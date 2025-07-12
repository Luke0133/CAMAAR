class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :fake_login

  private

  def fake_login
    session[:email] ||= "aluno@teste.com"
  end
end

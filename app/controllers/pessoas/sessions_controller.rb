# app/controllers/pessoas/sessions_controller.rb
class Pessoas::SessionsController < Devise::SessionsController
  layout 'login'  # Usa um layout diferente só na tela de login

  def after_sign_in_path_for(resource)
    flash[:notice] = "Login efetuado com sucesso"
    #homepage_path
  end
end
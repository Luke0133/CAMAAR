# app/controllers/pessoas/sessions_controller.rb
class Pessoas::SessionsController < Devise::SessionsController
  layout 'login'  # Usa um layout diferente só na tela de login

  # Se quiser customizar o comportamento, você pode sobrescrever os métodos aqui:
  # def create
  #   super
  # end
end
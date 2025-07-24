##
# Controladora responsável por checar se a pessoa tem cargo de admin
#
class Admin::BaseAdminController < ApplicationController
  before_action :authorize_admin!
end
class Tta::UsersController < ApplicationController
  unloadable

  before_action :authorize

  def index
  end
end

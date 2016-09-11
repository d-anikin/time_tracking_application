class TimelogController < ApplicationController
  unloadable
  before_action :require_login
  accept_api_auth :start, :update, :stop


  def start

  end

  def update
  end

  def stop
  end
end

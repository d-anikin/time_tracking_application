class Tta::SessionController < ApplicationController
  unloadable
  before_action :require_login
  before_action :verify_tta_session, only: [:destroy, :idle]
  accept_api_auth :create, :destroy, :idle

  def create
    User.current.update_attributes({
      tta_session: SecureRandom.hex(12),
      tta_status: :started,
      tta_status_updated_at: DateTime.current
    })

    respond_to do |format|
      format.api {
        render json: {
          version: Redmine::Plugin.find(:time_tracking_application).try(:version) || '0.0.0',
          user_name: User.current.name,
          tta_session: User.current.tta_session
        }
      }
    end
  end

  def destroy
    if params[:tta_session].blank? || !User.current.tta_session.eql?(params[:tta_session])
      puts User.current.tta_session, params[:tta_session]
      render_403
      return false
    end
    User.current.update_attributes({
      tta_session: nil,
      tta_status: :offline,
      tta_status_updated_at: DateTime.current
    })
    head :ok
  end

  def idle
    User.current.update_attributes({
      tta_status: :idle,
      tta_status_updated_at: DateTime.current
    })
    head :ok
  end

  private

  def verify_tta_session
    if params[:tta_session].blank? || !User.current.tta_session.eql?(params[:tta_session])
      puts User.current.tta_session, params[:tta_session]
      render_403
      return false
    end
  end
end

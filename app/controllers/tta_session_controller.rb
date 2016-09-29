class TtaSessionController < ApplicationController
  unloadable
  before_action :require_login
  before_action :verify_tta_session, only: [:destroy, :idle]
  accept_api_auth :create, :destroy, :idle

  def create
    @tta_data = TtaData.find_by_user_id(User.current.id) || TtaData.new(user_id: User.current.id)
    @tta_data.update_attributes({
      session: SecureRandom.hex(12),
      status: :online,
      status_updated_at: Time.now
    })

    respond_to do |format|
      format.api {
        render json: {
          version: Redmine::Plugin.find(:time_tracking_application).try(:version) || '0.0.0',
          user_name: User.current.name,
          day_starting_at: 8,
          day_ending_in: 18,
          lunch_starting_at: 13,
          lunch_ending_in: 14,
          tta_session: @tta_data.session
        }
      }
    end
  end

  def destroy
    if params[:tta_session].blank? || !@tta_data.session.eql?(params[:tta_session])
      puts User.current.tta_session, params[:tta_session]
      render_403
      return false
    end
    @tta_data.update_attributes({
      session: nil,
      status: :offline,
      status_updated_at: Time.now
    })
    head :ok
  end

  def idle
    @tta_data.update_attributes({
      status: :online,
      status_updated_at: Time.now
    })
    head :ok
  end

  private

  def verify_tta_session
    @tta_data = TtaData.find_by_user_id(User.current.id)
    if params[:tta_session].blank? || @tta_data.nil? || !@tta_data.session.eql?(params[:tta_session])
      render_403
      return false
    end
  end
end

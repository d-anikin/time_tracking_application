class TtaActivitiesController < ApplicationController
  unloadable
  before_action :authorize_global
  helper :tta

  def index
    user_ids = User.status(User::STATUS_ACTIVE).ids
    @data = TtaData
              .where(user_id: user_ids)
              .includes(:user, :active_issue)
              .order(:status)
    @summary_time = TimeEntry
                      .where(user_id: user_ids, spent_on: Date.today)
                      .group(:user_id).sum(:hours)
  end
end

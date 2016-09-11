class MainController < ApplicationController
  unloadable
  before_action :require_login
  accept_api_auth :details

  def details
    date = Date.today
    respond_to do |format|
      format.api {
        render json: {
          version: Redmine::Plugin.find(:time_tracking_application).try(:version) || '0.0.0',
          user_name: User.current.name,
          today: TimeEntry.where(spent_on: date).sum(:hours),
          this_week: TimeEntry.where(spent_on: [date.beginning_of_week..date.end_of_week]).sum(:hours),
          this_month: TimeEntry.where(spent_on: [date.beginning_of_month..date.end_of_month]).sum(:hours)
        }
      }
    end
  end
end

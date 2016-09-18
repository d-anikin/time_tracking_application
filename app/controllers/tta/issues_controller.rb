class Tta::IssuesController < ApplicationController
  unloadable

  before_action :require_login
  accept_api_auth :index

  def index
    @issues = Issue.visible.open
    @issues = apply_settings(@issues)
    call_hook(:controller_tta_issues_index, {:issues => @issues })
    @issues = @issues.includes(:assigned_to, :author, :status)
    @issues = @issues.limit(100)

    respond_to do |format|
      format.api {}
    end
  end

  private

  def apply_settings(issues)
    values = []
    values << nil if Setting.plugin_time_tracking_application['unassigned'].to_i > 0
    values << User.current.id if Setting.plugin_time_tracking_application['assigned_to_me'].to_i > 0
    issues = issues.where(assigned_to_id: values) if values.any?
    issues = issues.joins(:priority).order("#{IssuePriority.table_name}.position DESC") if Setting.plugin_time_tracking_application['sort_by_priority'].to_i > 0
    issues
  end
end

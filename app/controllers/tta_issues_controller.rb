class TtaIssuesController < ApplicationController
  unloadable

  before_action :require_login
  accept_api_auth :index

  def index
    assigned_ids = []
    assigned_ids << nil if Setting.plugin_time_tracking_application['unassigned'].to_i > 0
    assigned_ids << User.current.id if Setting.plugin_time_tracking_application['assigned_to_me'].to_i > 0
    if Redmine::Plugin.registered_plugins[:redmine_backlog]
      backlog = Backlog.query_backlog
      backlog = backlog.where("(issues.assigned_to_id IN (?) OR issues.status_id = ?)" ,
                              assigned_ids,
                              Setting.plugin_time_tracking_application['test_status'].to_i)
      backlog = backlog.includes(issue: [:assigned_to, :author, :status])
      @issues = backlog.map(&:issue).select(&:visible?)
    else
      @issues = Issue.visible.open
      @issues = @issues.joins(:priority).order("#{IssuePriority.table_name}.position DESC") if Setting.plugin_time_tracking_application['sort_by_priority'].to_i > 0
      @issues = @issues.where(assigned_to_id: assigned_ids) if assigned_ids.any?
      @issues = @issues.includes(:assigned_to, :author, :status)
      @issues = @issues.limit(100)
    end

    respond_to do |format|
      format.api {}
    end
  end
end

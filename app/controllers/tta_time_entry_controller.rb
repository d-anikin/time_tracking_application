class TtaTimeEntryController < ApplicationController
  unloadable
  before_action :find_issue, only: [:start]
  before_action :find_time_entry, only: [:update, :stop]
  before_action :authorize, :verify_tta_session

  accept_api_auth :start, :update, :stop
  helper :custom_fields
  include CustomFieldsHelper

  def start
    @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => User.current.today)
    @time_entry.assign_attributes(time_entry_params)
    @time_entry.hours = 0;
    move_issue_except(@issue) if change_status_on_stop?
    if @time_entry.save
      @issue.assigned_to = User.current if auto_assign_on_start?
      @issue.status_id = started_status if change_status_on_start?
      raise "Can`t update issue\n #{@issue.errors.full_messages}" if @issue.changed? and !@issue.save
      set_user_status(:busy, @issue.id)
      respond_to do |format|
        format.api  { render 'timelog/show' }
      end
    else
      respond_to do |format|
        format.api  { render_validation_errors(@time_entry) }
      end
    end
  end

  def update
    @time_entry.assign_attributes(time_entry_params)
    @time_entry.hours = ((Time.now.to_time - @time_entry.created_on.to_time) / 1.hours).round(2)
    if @time_entry.save
      set_user_status(:busy,  @time_entry.issue_id)
      respond_to do |format|
        format.api  { render 'timelog/show' }
      end
    else
      respond_to do |format|
        format.api  { render_validation_errors(@time_entry) }
      end
    end
  end

  def stop
    @time_entry.assign_attributes(time_entry_params)
    @time_entry.hours = ((Time.now.to_time - @time_entry.created_on.to_time) / 1.hours).round(2)
    if @time_entry.save
      @issue.status_id = stopped_status if change_status_on_stop? && in_process?(@issue)
      raise "Can`t update issue:\n #{@issue.errors.full_messages}" if @issue.changed? and !@issue.save
      set_user_status(:online, nil)
      respond_to do |format|
        format.api  { render 'timelog/show'}
      end
    else
      respond_to do |format|
        format.api  {
          puts @time_entry.errors.full_messages
          render_validation_errors(@time_entry)
        }
      end
    end
  end

private
  def plugin_settings
    @plugin_settings ||= Setting.plugin_time_tracking_application
  end

  def auto_assign_on_start?
    @issue.assigned_to.nil? and plugin_settings['auto_assign_on_start'].to_i > 0
  end

  def change_status_on_start?
    ids = plugin_settings['start_from_statuses'].map(&:to_i)
    ids.include?(@issue.status_id) && plugin_settings['change_status_on_start'].to_i > 0
  end

  def started_status
    plugin_settings['started_status'].to_i
  end

  def change_status_on_stop?
    plugin_settings['change_status_on_stop'].to_i > 0
  end

  def in_process?(issue)
    ids = plugin_settings['stop_from_statuses'].map(&:to_i)
    ids.include?(issue.status_id)
  end

  def stopped_status
    plugin_settings['stopped_status'].to_i
  end

  def move_issue_except(issue)
    ids = plugin_settings['stop_from_statuses'].map(&:to_i) - [issue.id]
    Issue.where(status_id: ids, assigned_to: User.current).find_each do |item|
      item.update_attributes(status_id: stopped_status)
    end
  end

  def time_entry_params
    params.permit(:activity_id, :comments)
  end

  def find_issue
    @issue = Issue.find(params[:issue_id])
    @project = @issue.project
  end

  def find_time_entry
    @time_entry = TimeEntry.find(params[:id])
    @issue = @time_entry.issue
    unless @time_entry.user == User.current
      render_403
      return false
    end
    @project = @time_entry.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def verify_tta_session
    @tta_data = TtaData.find_by_user_id(User.current.id)
    if params[:tta_session].blank? || @tta_data.nil? || !@tta_data.session.eql?(params[:tta_session])
      render_403
      return false
    end
  end

  def set_user_status(status, issue_id)
    if @tta_data.active_issue_id != issue_id
      @tta_data.assign_attributes({
        active_issue_id: issue_id,
        active_issue_started_at: Time.now
      })

      if issue_id.present? &&
          another_day?(@tta_data.first_issue_started_at, Time.now)
        @tta_data.first_issue_started_at = Time.now
      end
    end
    @tta_data.assign_attributes({
      status: status,
      status_updated_at: Time.now
    })
    @tta_data.save
  end

  def same_day?(dt1, dt2)
    return dt1 && dt2 && dt1.to_date != dt2
  end

  def another_day?(dt1, dt2)
    return !same_day?(dt1, dt2)
  end
end

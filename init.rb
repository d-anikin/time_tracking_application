Redmine::Plugin.register :time_tracking_application do
  name 'Time Tracking Application plugin'
  author 'Dmitrii Anikin'
  description 'Time Tracking Application'
  version '0.0.3'
  url 'http://www.redmine.org/plugins/time_tracking_application'
  author_url 'https://github.com/mrads'

  project_module :time_tracking_application do
    permission :timelog, 'tta_time_entry' => [:start, :update, :stop]
    permission :activities, 'tta_activities' => [:index], :public => true
  end

  menu :top_menu, :tta_users, { :controller => 'tta_activities', :action => 'index' }, :caption => :label_tta_activities

  settings  :default => {'empty' => true},
            :partial => 'settings/tta'
end

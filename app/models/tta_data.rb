class TtaData < ActiveRecord::Base
  belongs_to :user
  belongs_to :active_issue, class_name: 'Issue'
end

class CreateTtaData < ActiveRecord::Migration
  def change
    create_table :tta_data do |t|
      t.integer :user_id
      t.string :session
      t.string :status
      t.datetime :status_updated_at
      t.integer :active_issue_id
      t.datetime :active_issue_started_at
      t.datetime :first_issue_started_at
    end
  end
end

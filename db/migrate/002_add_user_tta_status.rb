class AddUserTtaStatus < ActiveRecord::Migration
  def change
    add_column :users, :tta_status, :string
    add_column :users, :tta_status_updated_at, :datetime
  end
end

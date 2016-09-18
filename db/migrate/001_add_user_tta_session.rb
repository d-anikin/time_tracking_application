class AddUserTtaSession < ActiveRecord::Migration
  def change
    add_column :users, :tta_session, :string
  end
end

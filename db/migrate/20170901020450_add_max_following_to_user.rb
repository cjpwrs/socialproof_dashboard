class AddMaxFollowingToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :max_following, :integer, default: 7000
  end
end

class AddStatusToSubscription < ActiveRecord::Migration[5.0]
  def change
    add_column :subscriptions, :status, :string
  end
end

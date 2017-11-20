class AddAuthorizenetFields < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :customer_profile_id, :integer
    add_column :users, :customer_payment_profile_id, :integer
    add_column :subscriptions, :authorizenet_subscription_id, :integer
  end
end

class RemovePlanFromSubscription < ActiveRecord::Migration[5.0]
  def change
    rename_column :subscriptions, :stripe_customer_token, :stripe_subscription_id
    remove_column :subscriptions, :plan
  end
end

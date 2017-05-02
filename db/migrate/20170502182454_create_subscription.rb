class CreateSubscription < ActiveRecord::Migration[5.0]
  def change
    create_table :subscriptions do |t|
      t.belongs_to :user, index: true
      t.string :stripe_customer_token

      t.timestamps null: false
    end
  end
end

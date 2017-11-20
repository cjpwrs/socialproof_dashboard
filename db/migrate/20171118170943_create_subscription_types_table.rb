class CreateSubscriptionTypesTable < ActiveRecord::Migration[5.0]
  def change
    create_table :subscription_types do |t|
      t.string :plan_name
      t.decimal :monthly_amount
      t.decimal :trial_amount
      t.string :description

      t.timestamps null: false
    end
  end
end

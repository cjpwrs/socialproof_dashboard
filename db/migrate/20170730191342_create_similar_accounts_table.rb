class CreateSimilarAccountsTable < ActiveRecord::Migration[5.0]
  def change
    create_table :similar_accounts do |t|
      t.belongs_to :user, index: true
      t.string :instagram_handle

      t.timestamps null: false
    end
  end
end

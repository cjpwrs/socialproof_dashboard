class AddStimAccountToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :stim_account, :string
  end
end

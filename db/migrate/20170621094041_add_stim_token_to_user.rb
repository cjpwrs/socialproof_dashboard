class AddStimTokenToUser < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'hstore'
    add_column :users, :stim_token, :string
    add_column :users, :stim_response, :hstore, default: {}, null: false
  end
end

class AddNeedsStimReconnect < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :needs_stim_reconnect, :boolean
  end
end

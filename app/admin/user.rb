ActiveAdmin.register User do
  sidebar "User Associations", only: [:show, :edit] do
    ul do
      li link_to "Target Accounts",    admin_user_target_accounts_path(resource)
      li link_to "Subscriptions",    admin_user_subscriptions_path(resource)
    end
  end

  index do
    selectable_column
    id_column
    column :email
    column :user_name
    column :created_at
    actions
  end

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :user_name
      f.input :stim_token
      f.input :stim_account
      f.input :account_id
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit!
    end
  end
end

ActiveAdmin.register TargetAccount do
  belongs_to :user
end

ActiveAdmin.register Subscription do
  belongs_to :user
end

ActiveAdmin.register User do
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

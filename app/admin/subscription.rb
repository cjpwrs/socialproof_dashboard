ActiveAdmin.register Subscription do
  index do
    selectable_column
    id_column
    column :user_id
    column :stripe_subscription_id
    column :status
    column :created_at
    actions
  end

  form do |f|
    f.inputs "User Details" do
      f.input :user_id
      f.input :stripe_subscription_id
      f.input :status
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit!
    end
  end
end

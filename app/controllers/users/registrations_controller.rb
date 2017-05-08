class Users::RegistrationsController < Devise::RegistrationsController
  def new
    @subscription = Subscription.new
    @stripe_list = Stripe::Plan.all
    @plans = @stripe_list[:data].map{ |plan| [plan[:name] + ' - ' +  (plan[:amount].to_f/100).to_s + '/month', plan[:id]]}
    super
  end

  def create
    build_resource sign_up_params
    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        return render :json => {:success => true}
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        return render :json => {:success => true}
      end
    else
      clean_up_passwords resource
      return render :json => {:success => false}
    end
  end
 
  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)
  end
end

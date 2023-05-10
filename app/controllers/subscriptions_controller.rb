class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

    def cancel
    # Fetch the user's Stripe Customer ID
    stripe_customer_id = current_user.stripe_customer_id

    # Fetch the user's subscription
    subscriptions = Stripe::Subscription.list(customer: stripe_customer_id)
    subscription = subscriptions.first

    # Cancel the subscription
    Stripe::Subscription.retrieve(subscription.id).cancel

    current_user.destroy
    sign_out(current_user)

    redirect_to root_path, notice: 'Your subscription has been canceled and your account has been deleted.'
  end
 
end

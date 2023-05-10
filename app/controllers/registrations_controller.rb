class RegistrationsController < Devise::RegistrationsController
  def create
    # Set your secret key. Remember to switch to your live secret key in production!
    Stripe.api_key = ENV['STRIPE_API_KEY']

    # Get the payment token submitted by the form:
    payment_token = params[:stripeToken]

    begin
      # Create a new customer in Stripe:
      customer = Stripe::Customer.create({
        email: params[:user][:email],
        payment_method: payment_token,
        invoice_settings: { default_payment_method: payment_token }
      })

      # Create a new subscription for the customer:
      subscription = Stripe::Subscription.create({
        customer: customer.id,
        items: [{ plan: "price_1N4gydBEGsuddqEpEzDvRtNj" }],
        expand: ["latest_invoice.payment_intent"],
        trial_period_days: 0
      })

      # Handle any exceptions that occur while processing the payment
    rescue Stripe::CardError => e
      flash[:error] = e.message
      render :new and return
    end

    # Create the user with the Stripe customer ID
    user = User.new(user_params)
    user.stripe_customer_id = customer.id
    user.stripe_subscription_id = subscription.id

    # Call the original Devise create action
    super
  end

 
  private

  def user_params
    params.require(:user).permit(:email, :name, :password, :password_confirmation)
  end
end


class ChargesController < ApplicationController

	def new
end

def create
  # Amount in cents
  @amount = 500

  # Get first customer with matching email to cardholder-email
  customers = Stripe::Customer.list(limit: 1, email: params[:"cardholder-email"])

  # Initialize empty customer variable to be set below
  customer = nil

  # If not matching customer, create a new one
  if customers.data.empty?
    customer = Stripe::Customer.create(
      :email => params[:"cardholder-email"],
      :source  => params[:stripeToken],
      :description => "Customer for #{params[:"cardholder-email"]}"
    )
  # If matching customer found, get from stripe  
  else
    customer = Stripe::Customer.retrieve(customers.data.first.id)
  end

  # Charge em' $5
  charge = Stripe::Charge.create(
    :customer    => customer.id,
    :amount      => @amount,
    :description => 'Stripe Elements Rails Charge',
    :currency    => 'usd'
  )

# errors
rescue Stripe::CardError => e
  flash[:error] = e.message
  redirect_to new_charge_path
end

end

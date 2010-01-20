# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class PerUserTaxExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/per_user_tax"

  # Please use per_user_tax/config/routes.rb instead for extension routes.

  # def self.require_gems(config)
  #   config.gem "gemname-goes-here", :version => '1.2.3'
  # end
  
  def activate
    CheckoutsController.class_eval do
      # register edit_hook and update_hook for each of the checkout states
      class_scoping_reader :taxation, Spree::Checkout::ActionOptions.new
    end

    Checkout.state_machines[:state] = StateMachine::Machine.new(Checkout, :initial => 'taxation') do
      after_transition :to => 'complete', :do => :complete_order
      before_transition :to => 'complete', :do => :process_payment
      after_transition :to => 'address', :do => :update_tax_charge

      event :next do
        transition :to => 'address', :from => 'taxation'
        transition :to => 'delivery', :from  => 'address'
        transition :to => 'payment', :from => 'delivery'
        transition :to => 'complete', :from => 'payment'
      end
    end

    Checkout.class_eval do
      validation_group :taxation, :fields => ["tax_exemption_name"]
      validates_length_of :tax_exemption_name, :minimum => 2, :if => :tax_exemption

      # We create tax charge only when we KNOW that user is not eligible for tax exempt.
      def update_tax_charge
        case tax_exemption
        when false
          order.tax_charges.create({
              :order => order,
              :description => I18n.t(:tax),
              :adjustment_source => order,
            }) if order.tax_charges.empty?
        when true
          order.tax_charges.each(&:destroy)
        when nil
          # Unless user chooses something don't create tax charge.
        end

        true
      end
    end

    Order.class_eval do
      def create_tax_charge
        # Do not create tax charge by default now.
        true
      end
    end
  end
end

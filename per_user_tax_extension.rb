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

    # Add your extension tab to the admin.
    # Requires that you have defined an admin controller:
    # app/controllers/admin/yourextension_controller
    # and that you mapped your admin in config/routes

    #Admin::BaseController.class_eval do
    #  before_filter :add_yourextension_tab
    #
    #  def add_yourextension_tab
    #    # add_extension_admin_tab takes an array containing the same arguments expected
    #    # by the tab helper method:
    #    #   [ :extension_name, { :label => "Your Extension", :route => "/some/non/standard/route" } ]
    #    add_extension_admin_tab [ :yourextension ]
    #  end
    #end

    # make your helper avaliable in all views
    # Spree::BaseController.class_eval do
    #   helper YourHelper
    # end

    Checkout.class_eval do
      after_save :update_tax_charge

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
        order.update_totals!

        true
      end
    end
    
    Order.class_eval do
      def create_tax_charge
        # Do not create tax charge by default now.
      end
    end
  end
end

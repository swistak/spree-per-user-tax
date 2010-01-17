class SetSettings < ActiveRecord::Migration
  def self.up
    add_column :checkouts, :tax_exemption, :boolean
    add_column :checkouts, :tax_exemption_name, :string

    Spree::Config.set(:show_price_inc_vat => false)
  end

  def self.down
  end
end
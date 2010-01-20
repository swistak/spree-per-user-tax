require File.dirname(__FILE__) + '/../test_helper'

class PerUserTaxExtensionTest < Test::Unit::TestCase
  
  # Replace this with your real tests.
  def test_this_extension
    flunk
  end
  
  def test_initialization
    assert_equal File.join(File.expand_path(RAILS_ROOT), 'vendor', 'extensions', 'per_user_tax'), PerUserTaxExtension.root
    assert_equal 'Per User Tax', PerUserTaxExtension.extension_name
  end
  
end

require 'minitest/autorun'
require 'minitest/rg'
require_relative '../models/transaction.rb'

class TestTransaction < MiniTest::Test
  def setup
    @transaction1 = Transaction.new('description' => 'Bought some shoes', 'amount' => 50.00, 'date' => '24/08/2018')
  end

  def test_transaction_has_description
    assert_equal('Bought some shoes', @transaction1.description)
  end

  def test_transaction_has_amount
    assert_equal(50.00, @transaction1.amount)
  end
end

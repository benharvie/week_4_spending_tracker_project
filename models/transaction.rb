require_relative '../db/sql_runner.rb'

class Transaction
  attr_accessor :id, :description, :amount, :transaction_date, :merchant_id, :tag_id
  def initialize(options)
    @id = options['id'].to_i if options['id']
    @description = options['description']
    @amount = options['amount']
    @transaction_date = options['transaction_date']
    @merchant_id = options['merchant_id']
    @tag_id = options['tag_id']
  end

  def save
    sql = "INSERT INTO transactions
          (description, amount, transaction_date, merchant_id, tag_id)
          VALUES
          ($1, $2, $3, $4, $5)
          RETURNING id"
    values = [@description, @amount, @transaction_date, @merchant_id, @tag_id]
    @id = SqlRunner.run(sql, values).first['id'].to_i
  end

  def update
    sql = "UPDATE transactions
          SET (description, amount, transaction_date, merchant_id, tag_id)
          = ($1, $2, $3, $4, $5)
          WHERE id = $6"
    values = [@description, @amount, @transaction_date, @merchant_id, @tag_id, @id]
    SqlRunner.run(sql, values)
  end

  def delete
    sql = "DELETE FROM transactions
          WHERE id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def merchant
    sql = "SELECT name FROM merchants
          WHERE id = $1"
    values = [@merchant_id]
    SqlRunner.run(sql, values).first['name'] if @merchant_id != nil
  end

  def tag
    sql = "SELECT category FROM tags
          WHERE id = $1"
    values = [@tag_id]
    SqlRunner.run(sql, values).first['category'] if @tag_id != nil
  end

  ### CLASS METHODS

  def self.delete_all
    sql = "DELETE FROM transactions"
    SqlRunner.run(sql)
  end

  def self.all
    sql = "SELECT * FROM transactions
          ORDER BY transaction_date ASC"
    result = SqlRunner.run(sql)
    result.map { |transaction| Transaction.new(transaction) }
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM transactions
          WHERE id = $1"
    values = [id]
    found = SqlRunner.run(sql, values)
    found.map { |transaction| Transaction.new(transaction) }
  end

  def self.find_by_merchant(id)
    sql = "SELECT * FROM transactions
          WHERE merchant_id = $1"
    values = [id]
    found = SqlRunner.run(sql, values)
    found.map { |transaction| Transaction.new(transaction) }
  end

  def self.find_by_tag(id)
    sql = "SELECT * FROM transactions
          WHERE tag_id = $1"
    values = [id]
    found = SqlRunner.run(sql, values)
    found.map { |transaction| Transaction.new(transaction) }
  end

  def self.find_by_date(date) # Needed?
    sql = "SELECT * FROM transactions
          WHERE transaction_date = $1"
    values = [date]
    found = SqlRunner.run(sql, values)
    found.map { |transaction| Transaction.new(transaction) }
  end

  def self.null_merchants(id)
    sql = "UPDATE transactions
          SET merchant_id = NULL
          WHERE merchant_id = $1"
    values = [id]
    SqlRunner.run(sql, values)
  end

  def self.null_tags(id)
    sql = "UPDATE transactions
          SET tag_id = NULL
          WHERE tag_id = $1"
    values = [id]
    SqlRunner.run(sql, values)
  end

  def self.total
    sql = "SELECT SUM(amount) FROM transactions"
    SqlRunner.run(sql).first['sum'].to_f
  end

  def self.date_between(start_date, end_date)
    sql = "SELECT * FROM transactions
          WHERE transaction_date
          BETWEEN
          $1 AND $2
          ORDER BY transaction_date ASC"
    values = [start_date, end_date]
    result = SqlRunner.run(sql, values)
    result.map { |transaction| Transaction.new(transaction) }
  end
end

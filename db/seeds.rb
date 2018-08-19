# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
MONDO_TOKEN = ENV['MONDO_TOKEN']
ACCOUNT_ID = ENV['ACCOUNT_ID']
SEED_START_DATE = ENV['SEED_START_DATE']

def initialize_mondo_client
  Mondo::Client.new(
    token: MONDO_TOKEN,
    account_id: ACCOUNT_ID
  )
end

def seed_transactions
  mondo = initialize_mondo_client
  transactions = mondo.transactions(since: SEED_START_DATE)
  puts "Transactions: #{transactions.count}"
  transactions.each do |transaction|
    merchant = transaction.merchant
    unless merchant.nil?
      internal_merchant = Merchant.create(
        name: merchant.name,
        logo: merchant.logo,
        monzo_id: merchant.id,
        group_id: merchant.group_id,
        created: merchant.created,
        address: merchant.address
      )
    end
    Transaction.create(
      amount: transaction.amount,
      created: transaction.created,
      currency: transaction.currency,
      description: transaction.description,
      merchant_id: internal_merchant&.id,
      notes: transaction.notes,
      is_load: transaction.is_load,
      settled: transaction.settled,
      monzo_id: transaction.id
    )
  end
end

def seed_categories
  categories = [
    'Food/Toiletries',
    'Savings',
    'Accommodation',
    'Learning To Drive',
    'Travel',
    'Other',
    'Phone',
    'Tech',
    'Games',
    'Social'
  ]
  categories.each do |c|
    Category.create(name: c)
  end
end

def enable_webhook
  mondo = initialize_mondo_client
  mondo.register_web_hook("#{ENV['ROOT_URL']}/monzo_webhook_add") 
end

seed_transactions
seed_categories
enable_webhook

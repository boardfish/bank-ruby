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

def seed_transactions(from = SEED_START_DATE)
  mondo = initialize_mondo_client
  transactions = mondo.transactions(since: from)
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
    if transaction.decline_reason.nil?
      Transaction.create(
        amount: transaction.amount,
        created: transaction.created,
        currency: transaction.currency,
        description: transaction.description,
        merchant_id: internal_merchant&.id,
        notes: transaction.notes,
        is_load: transaction.is_load,
        settled: transaction.settled,
        category_id: transaction.category.nil? ? nil : Category.find_or_create_by(name: transaction.category).id,
        monzo_id: transaction.id,
        decline_reason: transaction.decline_reason
      )
    end
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
    Category.find_or_create_by(name: c)
  end
end

def enable_webhook
  mondo = initialize_mondo_client
  mondo.register_web_hook("#{ENV['ROOT_URL']}/monzo_webhook_add")
end

seed_transactions
seed_categories
enable_webhook

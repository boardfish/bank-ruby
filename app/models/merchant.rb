# frozen_string_literal: true

# Merchant: Represents the second party in a Monzo transaction.
class Merchant < ApplicationRecord
  validates_presence_of :monzo_id
  validates_uniqueness_of :monzo_id

  def address_data
    return nil if address.nil?
    source_string = address.delete('\\').strip
    source_string.slice! '#<Mondo::Address'
    source_string.chomp! '>'
    JSON.parse(source_string.gsub('=>', ':'))
  end
end

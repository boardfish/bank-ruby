# frozen_string_literal: true

# Merchant: Represents the second party in a Monzo transaction.
class Merchant < ApplicationRecord
  validates_presence_of :monzo_id
  validates_uniqueness_of :monzo_id
end

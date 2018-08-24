# frozen_string_literal: true

# Budget: Represents how much the user should be aiming to spend maximum in one
# category in one month
class Budget < ApplicationRecord
  belongs_to :category
  before_validation :beginning_of_month
  before_validation :not_duplicate
  validates_presence_of :category
  validates_presence_of :amount
  validates_presence_of :month

  def difference(transaction)
    if transaction.class.name.demodulize == 'Relation'
      amount - transaction.sum(:amount)
    else
      amount - transaction.amount
    end
  end

  private

  def beginning_of_month
    self.month = month.beginning_of_month
  end

  def not_duplicate
    errors.add(:duplicate, 'cannot be duplicate') if Budget.where(
      category_id: category_id,
      month: month
    ).count.positive?
  end
end

class Transaction < ApplicationRecord
  def name
    if !merchant_id.nil?
      Merchant.find(merchant_id).name
    elsif description.empty?
      notes
    elsif description.start_with?('pot_')
      "Pot: #{description}"
    else
      description
    end
  end

  def merchant
    Merchant.find(merchant_id) unless merchant_id.nil?
  end

  def category
    if !category_id.nil?
      Category.find(category_id).name
    else
      monzo_category
    end
  end
end

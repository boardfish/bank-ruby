# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Budget, type: :model do
  it 'should not save if not unique' do
    FactoryBot.build(:category).save
    save_results = Array.new(2, DateTime.now.beginning_of_month).map do |date|
      FactoryBot.build(:budget, month: date, category: Category.first).save
    end
    expect(save_results).to eq [true, false]
  end

  it 'should raise an error if not unique' do
    FactoryBot.build(:category).save
    save_results = Array.new(2, DateTime.now.beginning_of_month).map do |date|
      FactoryBot.build(:budget, month: date, category: Category.first)
    end
    save_results.map(&:save)
    expect(save_results[1].errors.details.keys).to eq [:duplicate]
  end

  it 'should return the difference between its amount and a transaction\'s' do
    FactoryBot.build(:category).save
    FactoryBot.build(:budget, month: DateTime.now.beginning_of_month,
                              category: Category.first).save
    FactoryBot.build(:transaction).save
    expect(Budget.last.difference(Transaction.last)).to eq 0
  end

  it 'should return the difference between its amount and some transactions' do
    FactoryBot.build(:category).save
    FactoryBot.build(:budget, month: DateTime.now.beginning_of_month,
                              category: Category.first).save
    FactoryBot.build(:transaction).save
    trans2 = FactoryBot.build(:transaction, monzo_id: 'fhasdgjk')
    trans2.save
    expect(Budget.last.difference(Transaction.all)).to eq -0.999e1
  end
end

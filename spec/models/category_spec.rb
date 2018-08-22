# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:default_build) { FactoryBot.build(:category) }
  let(:random_build) { FactoryBot.build(:category, name: 'tEsT CaTeGoRy 674!') }
  let(:blank_build) { FactoryBot.build(:category, name: '') }

  it 'should save if all attributes are correct' do
    expect(default_build.save).to be true
  end

  it 'must be saved with a snake_case name' do
    validated_category = random_build
    validated_category.valid?
    expect(validated_category.name).to eq('test_category_674')
  end

  it 'should have a unique name' do
    FactoryBot.build(:category).save
    duplicate_category = FactoryBot.build(:category)
    duplicate_category.valid?
    expect(duplicate_category.errors[:name])
      .to include('has already been taken')
  end

  it 'should not have an empty name' do
    blank_category = blank_build
    blank_category.valid?
    expect(blank_category.errors[:name]).to include('can\'t be blank')
  end
end

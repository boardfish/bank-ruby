# frozen_string_literal: true

# Category: Group of purchases under a particular name. Represents a user-
# assigned budget.
class Category < ApplicationRecord
  before_validation :snakecase_name
  validates_uniqueness_of :name, case_sensitive: false
  validates_presence_of :name

  def snakecase_name
    self.name = name.parameterize.underscore
  end
end

# frozen_string_literal: true

class Account < ApplicationRecord
  self.table_name = 'account'
  has_many :phone_numbers
end

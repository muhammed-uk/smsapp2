# frozen_string_literal: true

class PhoneNumber < ApplicationRecord
  self.table_name = 'phone_number'
  belongs_to :account
end

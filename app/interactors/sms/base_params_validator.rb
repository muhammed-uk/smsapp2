# frozen_string_literal: true

module Sms
  FIELDS_CRITERIA = {
    'from' => { 'type' => 'String', 'lt' => 6, 'gt' => 16 },
    'to' => { 'type' => 'String', 'lt' => 6, 'gt' => 16 },
    'text' => { 'type' => 'String', 'lt' => 1, 'gt' => 120 }
  }.freeze

  class BaseParamsValidator
    include Interactor
    delegate :current_user, :params, to: :context

    def call
      check_required_fields
      check_fields_validity
      check_for_phone_number
    end

  protected

    def check_required_fields
      missing_fields = Sms::FIELDS_CRITERIA.keys.map do |required_field|
        "#{required_field} is missing" unless
          params.key?(required_field)
      end.compact

      context.fail!(errors: missing_fields) if missing_fields.present?
    end

    def check_fields_validity
      invalid_fields = []
      Sms::FIELDS_CRITERIA.each do |key, value_hash|
        value = params[key]
        next unless value.class.to_s != value_hash['type'] ||
          value.length > value_hash['gt'] ||
          value.length < value_hash['lt']

        invalid_fields << "#{key} is invalid"
      end

      context.fail!(errors: invalid_fields) if invalid_fields.present?
    end

    def check_for_phone_number
      context.fail!(errors: ["#{params["to"]} not found"]) unless
        current_user.phone_numbers.pluck(:number).include?(params['to'])
    end
  end
end

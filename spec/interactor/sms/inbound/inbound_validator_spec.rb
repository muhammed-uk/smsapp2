require 'rails_helper'
require 'spec_helper'

module Sms
  module Inbound
    RSpec.describe InboundValidator do
      describe 'Inherit Sms::BaseParamsValidator' do
        it 'responds to .call' do
          expect(described_class.respond_to?(:call)).to eq(true)
        end
      end
    end
  end
end

require 'rails_helper'
require 'spec_helper'

RSpec.describe 'Routes', type: :routing do
  describe 'api' do
    it 'routes /api/inbound/sms to the /api/sms/inbound' do
      expect(post('/api/inbound/sms')).to route_to('api/sms#inbound')
    end

    it 'routes /api/outbound/sms to the /api/sms/outbound' do
      expect(post('/api/outbound/sms')).to route_to('api/sms#outbound')
    end
  end
end

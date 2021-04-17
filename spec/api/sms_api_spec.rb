require 'rails_helper'
require 'spec_helper'

RSpec.describe Api::SmsController, type: :request do
  before(:all) do
    setup_accounts_and_numbers
  end

  describe 'POST: Inbound' do
    context 'when validation succeeds' do
      it 'shows inbound sms ok' do
        expect(Sms::Inbound::InboundValidator).to receive(:call).and_return(
          OpenStruct.new(success?: true)
        )
        expect(Sms::SaveToCache).to receive(:call)
        post('/api/inbound/sms', params: {}, headers: @headers)
        expect(response).to have_http_status(:ok)
        expected_response = { 'message' => 'Inbound SMS OK' }
        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end

    context 'when validation fails' do
      it 'shows the error' do
        validation_errors = ['from is missing', 'to is missing', 'text is missing']
        expect(Sms::Inbound::InboundValidator).to receive(:call).and_return(
          OpenStruct.new(success?: false, errors: validation_errors)
        )
        post('/api/inbound/sms', params: {}, headers: @headers)
        expect(response).to have_http_status(:unprocessable_entity)
        expected_response = { 'message' => '', 'errors' => validation_errors }
        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end
  end

  describe 'POST: Outbound' do
    context 'when validation succeeds' do
      it 'shows outbound sms ok' do
        expect(Sms::Outbound::OutboundValidator).to receive(:call).and_return(
          OpenStruct.new(success?: true)
        )
        expect(Sms::SaveToCache).not_to receive(:call)
        post('/api/outbound/sms', params: {}, headers: @headers)
        expect(response).to have_http_status(:ok)
        expected_response = { 'message' => 'Outbound SMS OK' }
        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end

    context 'when validation fails' do
      it 'shows the error' do
        validation_errors = ['from is missing', 'to is missing', 'text is missing']
        expect(Sms::Outbound::OutboundValidator).to receive(:call).and_return(
          OpenStruct.new(success?: false, errors: validation_errors)
        )
        post('/api/outbound/sms', params: {}, headers: @headers)
        expect(response).to have_http_status(:unprocessable_entity)
        expected_response = { 'message' => '', 'errors' => validation_errors }
        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end
  end
end

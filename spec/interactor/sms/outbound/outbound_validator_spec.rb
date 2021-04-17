require 'rails_helper'
require 'spec_helper'

module Sms
  module Outbound
    RSpec.describe OutboundValidator do
      before(:all) do
        @params = {
          from: '8075307117',
          to: '9746473595',
          text: 'Helo'
        }.with_indifferent_access
      end


      describe '.call' do
        context 'inherits Sms::BaseParamsValidator' do
          it 'call parental methods (super)' do
            expect(Sms::BaseParamsValidator).to receive(:call)
            described_class.call(params: @params)
          end
        end

        context 'overrides call method and check additional things' do
          context 'check limit reached' do
            before(:all) { @cache_key = "from-#{@params[:from]}" }

            context 'entry present in cache; limit not reached yet' do
              before do
                mocked_cache_data = {
                  count: 50,
                  expires_in: Time.now + 2.hours
                }

                Rails.cache.write(@cache_key, mocked_cache_data, expires_in: 2.hours)
              end

              it 'adds up the outbound request count' do
                response = described_class.call(params: @params)
                expect(response.success?).to eq(true)
                updated_cache = Rails.cache.read(@cache_key)
                expect(updated_cache[:count]).to eq(51)
              end
            end

            context 'limit exceeded' do
              it 'should return error message' do
                response = described_class.call(params: @params)
                expect(response.success?).to eq(false)
                expect(response.errors).to eq(["limit reached for from #{@params[:from]}"])
                Rails.cache.delete(@cache_key)
              end
            end
          end

          context 'check blacklisted' do
            before(:all) do
              @cache_key = "block-from-#{@params[:from]}-to-#{@params[:to]}"
            end

            context 'black listed entry not present' do
              it 'should bypass the check' do
                response = described_class.call(params: @params)
                expect(response.success?).to eq(true)
              end
            end

            context 'black listed entry not present' do
              before { Rails.cache.write(@cache_key, { from: @params[:from] }, expires_in: 10.minutes) }

              it 'should return the blacklisted message' do
                response = described_class.call(params: @params)
                expect(response.success?).to eq(false)
                expected_error = ["SMS from #{@params[:from]} to #{@params[:to]} blocked by STOP request"]
                expect(response.errors).to eq(expected_error)
              end

              after { Rails.cache.delete(@cache_key) }
            end
          end
        end
      end
    end
  end
end

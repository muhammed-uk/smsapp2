require 'rails_helper'
require 'spec_helper'

module Sms
  RSpec.describe SaveToCache do
    before(:all) do
      @params = {
        from: '8075307117',
        to: '9746473595',
        text: 'Helo'
      }.with_indifferent_access
    end

    let(:save_to_cache) { described_class.call(params: @params) }

    context 'when text is not STOP' do
      it 'should keep record of each inbound request in cache for rate limiting' do
        cache_key = "from-#{@params[:from]}"
        save_to_cache
        cached_data = Rails.cache.read(cache_key)
        expect(cached_data).not_to be_empty
        expect(cached_data.keys).to match_array(%i[count expires_in])
        expect(cached_data[:count]).to eq(1)
      end

      it 'should not add block entry' do
        save_to_cache
        block_cache_key = "block-from-#{@params[:from]}-to-#{@params[:to]}"
        cached_data = Rails.cache.read(block_cache_key)
        expect(cached_data).to be_nil
      end
    end

    context 'when text is STOP' do
      it 'should store the request entry to block further request' do
        params = @params.tap do |key|
          key[:text] = 'STOP'
        end

        save_to_cache
        block_cache_key = "block-from-#{params[:from]}-to-#{params[:to]}"
        cached_data = Rails.cache.read(block_cache_key)
        expect(cached_data).not_to be_empty
        expect(cached_data.keys).to match_array(%i[from to])
      end
    end
  end
end

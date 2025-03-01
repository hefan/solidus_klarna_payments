# frozen_string_literal: true

require 'spec_helper'

describe SolidusKlarnaPayments::PlaceOrderWithAuthorizationTokenService do
  describe '#call' do
    subject(:service) { described_class.call(order: order, payment_source: payment_source) }

    let(:order) { create(:order_with_line_items) }
    let(:payment_method) { build(:klarna_credit_payment_method) }
    let(:payment_source) { build(:klarna_credit_payment, authorization_token: authorization_token, payment_method: payment_method) }

    let(:authorization_token) { 'AUTHORIZATION_TOKEN' }
    let(:klarna_client) { instance_double('Klarna::Payment') }
    let(:order_serializer) { instance_double('SolidusKlarnaPayments::OrderSerializer') }

    before do
      allow(Klarna).to receive(:client).and_return(klarna_client)
      allow(klarna_client).to receive(:place_order)

      allow(SolidusKlarnaPayments::OrderSerializer)
        .to receive(:new)
        .and_return(order_serializer)

      allow(order_serializer).to receive(:to_hash).and_return({ serialized_order: 'yes' })
    end

    it 'calls the Klarna payment place order method' do
      service

      expect(klarna_client)
        .to have_received(:place_order)
        .with(authorization_token, { serialized_order: 'yes' })
    end
  end
end

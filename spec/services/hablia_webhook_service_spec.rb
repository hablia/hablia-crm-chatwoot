require 'rails_helper'

describe HabliaWebhookService do
  describe '.deliver' do
    let(:url) { 'https://hablia.example.com/webhooks/chatwoot' }
    let(:payload) { { user: { id: 7, email: 'owner@example.com', name: 'Owner' }, accounts: [{ id: 1, name: 'Acme' }] } }

    it 'does nothing when HABLIA_WEBHOOK_URL is not set' do
      with_modified_env HABLIA_WEBHOOK_URL: nil, HABLIA_WEBHOOK_SECRET: 'shared-secret' do
        expect(WebhookJob).not_to receive(:perform_later)

        described_class.deliver('set_new_password', payload)
      end
    end

    it 'signs the webhook with HABLIA_WEBHOOK_SECRET' do
      with_modified_env HABLIA_WEBHOOK_URL: url, HABLIA_WEBHOOK_SECRET: 'shared-secret' do
        expect(WebhookJob).to receive(:perform_later).with(
          url, hash_including(event: 'set_new_password', **payload), secret: 'shared-secret'
        ).once

        described_class.deliver('set_new_password', payload)
      end
    end

    it 'sends the webhook without a signature when HABLIA_WEBHOOK_SECRET is not set' do
      with_modified_env HABLIA_WEBHOOK_URL: url, HABLIA_WEBHOOK_SECRET: nil do
        expect(WebhookJob).to receive(:perform_later).with(
          url, hash_including(event: 'set_new_password', **payload), secret: nil
        ).once

        described_class.deliver('set_new_password', payload)
      end
    end
  end
end

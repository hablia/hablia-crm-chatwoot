class HabliaWebhookService
  WEBHOOK_URL_ENV = 'HABLIA_WEBHOOK_URL'.freeze
  # Secreto compartido con el backend de Hablia (hablia-chatwoot-webhook-secret). Con él, Webhooks::Trigger
  # firma el cuerpo con HMAC-SHA256 (X-Chatwoot-Signature + X-Chatwoot-Timestamp) y el backend verifica al emisor.
  # Sin él la llamada sale sin firmar y el backend decide según ff_backend_chatwoot_webhook_secret_enforce (HAB-514).
  WEBHOOK_SECRET_ENV = 'HABLIA_WEBHOOK_SECRET'.freeze

  def self.deliver(event, payload = {})
    webhook_url = ENV.fetch(WEBHOOK_URL_ENV, nil)
    return if webhook_url.blank?

    data = {
      event: event,
      timestamp: Time.current.iso8601
    }.merge(payload)

    WebhookJob.perform_later(webhook_url, data, secret: ENV.fetch(WEBHOOK_SECRET_ENV, nil))
  end
end

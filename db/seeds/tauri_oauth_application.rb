# frozen_string_literal: true

redirect_uri = ENV.fetch("TAURI_OAUTH_REDIRECT_URI", "circuitverse://auth")

application = Doorkeeper::Application.find_or_initialize_by(name: TAURI_DESKTOP_OAUTH_APPLICATION_NAME)
application.redirect_uri = redirect_uri
application.confidential = false
application.scopes = "public profile email"
application.save!

Rails.logger.info(
  "Tauri desktop OAuth application ready: uid=#{application.uid} redirect_uri=#{application.redirect_uri}"
)

# frozen_string_literal: true

require "rails_helper"
require "securerandom"
require "base64"
require "digest"

RSpec.describe "OAuth PKCE flow", type: :request do
  let(:user) { create(:user, password: "password", password_confirmation: "password") }
  let(:application) do
    Doorkeeper::Application.create!(
      name: "PKCE Client",
      redirect_uri: "https://client.example.com/callback",
      confidential: false
    )
  end

  # From RFC 7636: S256 code challenge method
  def generate_pkce_pair
    verifier = SecureRandom.urlsafe_base64(64)
    challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier)).delete("=")
    [verifier, challenge]
  end

  def extract_code(redirect_location)
    Rack::Utils.parse_query(URI.parse(redirect_location).query)["code"]
  end

  def authorize_with_pkce
    sign_in user

    code_verifier, code_challenge = generate_pkce_pair

    auth_params = {
      response_type: "code",
      client_id: application.uid,
      redirect_uri: application.redirect_uri,
      scope: "public",
      code_challenge: code_challenge,
      code_challenge_method: "S256"
    }

    get "/oauth/authorize", params: auth_params
    expect(response).to have_http_status(:ok)

    post "/oauth/authorize", params: auth_params.merge(commit: "Authorize")

    expect(response).to have_http_status(:found)
    code = extract_code(response.headers["Location"])
    expect(code).to be_present

    [code_verifier, code]
  end

  it "returns to the original /oauth/authorize request after signing in" do
    _code_verifier, code_challenge = generate_pkce_pair

    auth_params = {
      response_type: "code",
      client_id: application.uid,
      redirect_uri: application.redirect_uri,
      scope: "public",
      code_challenge: code_challenge,
      code_challenge_method: "S256",
      state: "csrf-state-value"
    }

    get "/oauth/authorize", params: auth_params
    expect(response).to redirect_to(new_user_session_path)

    post "/users/sign_in", params: { user: { email: user.email, password: "password" } }
    expect(response).to redirect_to(%r{/oauth/authorize\?})

    follow_redirect!
    expect(response).to have_http_status(:ok)
  end

  it "returns an authorization code via the UI" do
    _code_verifier, code = authorize_with_pkce

    expect(code).to be_present
  end

  it "exchanges an authorization code + PKCE verifier for an access token" do
    code_verifier, code = authorize_with_pkce

    post "/oauth/token", params: {
      grant_type: "authorization_code",
      code: code,
      redirect_uri: application.redirect_uri,
      client_id: application.uid,
      code_verifier: code_verifier
    }

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body["access_token"]).to be_present
    expect(body["token_type"]).to eq("Bearer")
  end

  it "rejects a token exchange with a code_verifier that doesn't match the code_challenge" do
    _code_verifier, code = authorize_with_pkce

    post "/oauth/token", params: {
      grant_type: "authorization_code",
      code: code,
      redirect_uri: application.redirect_uri,
      client_id: application.uid,
      code_verifier: "#{SecureRandom.urlsafe_base64(64)}-wrong"
    }

    expect(response).to have_http_status(:bad_request)
    expect(response.parsed_body["error"]).to eq("invalid_grant")
  end
end

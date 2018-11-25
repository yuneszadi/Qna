module OmniauthMacros
  def mock_auth_hash(provider, email = nil)
    OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new(
      provider: provider.to_s,
      uid: '123545',
      info: {
        name: 'mockuser',
        image: 'mock_user_thumbnail_url',
        email: email
      },
      credentials: {
        token: 'mock_token',
        secret: 'mock_secret'
      }
    )
  end
end

# frozen_string_literal: true

module Doorkeeper
  class JsonWebTokenGenerator
    def self.generate(options)
      resource_owner_id = options[:resource_owner_id]
      return Doorkeeper::OAuth::Helpers::UniqueToken.generate unless resource_owner_id

      user = User.find_by(id: resource_owner_id)
      return Doorkeeper::OAuth::Helpers::UniqueToken.generate unless user

      JsonWebToken.encode(user_id: user.id, username: user.name, email: user.email)
    end
  end
end

class TokenManager

  def self.tokens_by_user_id
    @tokens_by_user_id ||= {}
  end

  def self.tokens_by_value
    @tokens_by_value ||= {}
  end

  def self.generate_token(user_id)
    tokens_by_value.delete(tokens_by_user_id[user_id])
    token = SecureRandom.urlsafe_base64
    tokens_by_user_id[user_id] = token
    tokens_by_value[token] = user_id
  end

  def self.revoke_token(user_id)
    token = tokens_by_user_id.delete user_id
    tokens_by_value.delete token
  end

end
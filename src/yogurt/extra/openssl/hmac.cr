class OpenSSL::HMAC
  def self.base64digest(algorithm : OpenSSL::Algorithm, key, data) : String
    Base64.strict_encode digest(algorithm, key, data).hexstring
  end
end

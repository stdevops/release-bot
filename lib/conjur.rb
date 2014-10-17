ENV['CONJUR_ENV'] = 'production'

if ( account = ENV['CONJUR_ACCOUNT'] ) && ( certificate = ENV['CONJUR_SSL_CERTIFICATE'] ) && ENV['CONJUR_APPLIANCE_URL']
  require 'openssl'
  File.write(cert_file = "conjur-#{account}.pem", certificate)
  OpenSSL::SSL::SSLContext::DEFAULT_CERT_STORE.add_file cert_file
end

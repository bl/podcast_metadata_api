# load S3 configuration from config/initializers configuration files
if Rails.env.test? || Rails.env.development?
  CarrierWave.configure do |config|
      config.storage = :file
  end
end

if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: Settings.carrier_wave.aws_access_key_id,
      aws_secret_access_key: Settings.carrier_wave.aws_secret_access_key
    }
    config.fog_directory  = Settings.carrier_wave.fog_directory
    #config.fog_public = false # optiona, defaults to true
  end
end

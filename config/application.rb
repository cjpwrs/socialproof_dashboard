require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SocialProof
  class Application < Rails::Application

    config.middleware.use(Rack::Tracker) do
      handler :google_adwords_conversion, { id: 856813010,
                                            language: "en",
                                            format: "3",
                                            color: "ffffff",
                                            label: "4FfhCIb1628Q0tvHmAM",
                                            currency: "USD",
                                            remarketing_only: false }

      handler :facebook_pixel, { id: '255880641501778' }
    end
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end

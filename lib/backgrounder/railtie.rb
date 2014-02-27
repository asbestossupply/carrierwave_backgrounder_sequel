module CarrierWave
  module Backgrounder
    class Railtie < Rails::Railtie
      initializer "carrierwave_backgrounder.sequel" do
        require 'backgrounder/orm/sequel' if defined?(Sequel)
      end
    end
  end
end
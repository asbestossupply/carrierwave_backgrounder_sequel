module CarrierWave
  module Workers
    class Base
      def perform(*args)
        set_args(*args) if args.present?
        constantized_resource[id]
      rescue *not_found_errors
      end

      private
      alias :old_not_found_errors :not_found_errors
      def not_found_errors
        old_not_found_errors.tap do |errors|
          errors << ::Sequel::NoMatchingRow if defined?(::Sequel)
        end
      end

    end
  end
end

module Sequel
  module Plugins
    module CarrierWaveBackgrounder
      def self.apply(model, options = {})
        Rails.logger.warn 'SELF.APPLY'
        model.plugin :hook_class_methods
        model.plugin :dirty
      end

      module ClassMethods
        include CarrierWave::Backgrounder::ORM::Base

        # use base process_in_background and add column to class variable
        def process_in_background(column, worker=::CarrierWave::Workers::ProcessAsset)
          super
          (@@_carrierwave_process_in_background ||= {})[:"#{column}"] = worker
        end

        # use base store_in_background and add column to class variable
        def store_in_background(column, worker=::CarrierWave::Workers::StoreAsset)
          super
          (@@_carrierwave_store_in_background ||= {})[:"#{column}"] = worker
        end
        def _define_shared_backgrounder_methods(mod, column, worker)
          before_save do
            send(:"set_#{column}_processing") if send(:"enqueue_#{column}_background_job?")
          end

          after_commit do
            send(:"enqueue_#{column}_background_job") if send(:"enqueue_#{column}_background_job?")
          end

          super

          class_eval  <<-RUBY, __FILE__, __LINE__ + 1
            def enqueue_#{column}_background_job
              if enqueue_#{column}_background_job?
                super
                @#{column}_changed = false
              end
            end

            def #{column}_updated?
              @#{column}_changed
            end

            def #{column}=(val)
              @#{column}_changed = true
              super
            end
          RUBY
        end
      end # ClassMethods

      module InstanceMethods
        def update_attribute(col, val)
          h = {}
          h[col] = val
          self.set(h)
          self.save(:columns=>[col], :validate=>false)
        end
      end
    end
  end
end

Sequel::Model.plugin :carrier_wave_backgrounder
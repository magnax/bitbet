# frozen_string_literal: true

BitbetTk::Application.config.secret_key_base = if Rails.env.development? || Rails.env.test?
                                                 ('666' * 10)
                                               else
                                                 ENV.fetch('SECRET_TOKEN', nil)
                                               end

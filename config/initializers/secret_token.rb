BitbetTk::Application.config.secret_key_base = if Rails.env.development? or Rails.env.test?
  ('666' * 10)
else
  ENV['SECRET_TOKEN']
end

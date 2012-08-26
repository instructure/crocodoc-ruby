Crocodoc.configure do |config|
  config.token = YAML.load_file(Rails.root.join("config/crocodoc.yml"))[Rails.env]['token']
end

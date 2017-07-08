require_relative './ad_unit_bot.rb'

agent = AdUnitBot.new('test@test.com',
                      'password',
                      'app_name.com',
                      'standard')

@connection_attempt = 0

begin
  puts "Connecting with #{AdUnitBot::TARGET_URL}"
  agent.connect_to_site
rescue Selenium::WebDriver::Error::UnknownError, RuntimeError
  @connection_attempt += 1
  retry if @connection_attempt < 3
  puts 'Check you internet connection'
  exit
end

agent.app_present? ? agent.create_ad_block : agent.new_app

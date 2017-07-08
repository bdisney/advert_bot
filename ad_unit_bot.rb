require 'rubygems'
require 'selenium-webdriver'
require 'capybara'
require 'capybara/dsl'

Capybara.run_server = false
Capybara.current_driver = :selenium

class AdUnitBot
  include Capybara::DSL

  TARGET_URL      = 'https://target.my.com'.freeze
  DELAY           = Selenium::WebDriver::Wait.new(timeout: 50)
  WHERE_TO_BEGIN  = 'С чего начать?'.freeze
  CREATE_PLATFORM = 'Создать площадку'.freeze
  CREATE_BLOCK    = 'Создать блок'.freeze

  def initialize(email, password, app_name, block_type)
    @email = email
    @password = password
    @app_name = app_name
    @block_type = block_type
  end

  def connect_to_site
    visit TARGET_URL
    DELAY.until { has_xpath?(login_path) }
    has_xpath?(login_path) ? login : (raise RuntimeError 'Connection error')
  end

  def login
    find(:xpath, login_path).click

    fill_in 'Email или телефон', with: @email
    fill_in 'Пароль', with: @password

    click_button('Sign in')
    raise 'Invalid login or password' unless login_successfull?
  end

  def login_successfull?
    DELAY.until { has_xpath?(path_after_login) || has_content?('Invalid login or password') }
    has_xpath?(path_after_login)
  end

  def app_present?
    DELAY.until { has_content?(WHERE_TO_BEGIN) || has_link?(CREATE_PLATFORM) }
    has_link?(@app_name)
  end

  def new_app
    click_on('Заведите')      if has_content?(WHERE_TO_BEGIN)
    click_on(CREATE_PLATFORM) if has_content?(CREATE_PLATFORM)

    create_app
  end

  def create_app
    click_on(CREATE_PLATFORM)
    DELAY.until { has_content?('Ссылка на площадку') }

    fill_in 'Назовите вашу площадку', with: @app_name
    fill_in 'Введите ссылку на площадку', with: @app_name
    DELAY.until { has_content?('Рекламный блок') }

    choose_block.click
    find(:xpath, "//span[text()='#{CREATE_PLATFORM}']").click
    puts 'New app was successfully created.'
  end

  def create_ad_block
    click_link(@app_name)
    DELAY.until { has_link?(CREATE_BLOCK) }
    click_on(CREATE_BLOCK)

    begin
      DELAY.until { has_content?('Типы блоков') }
      raise 'Placement format is no longer available' if has_content?('Формат размещения больше вам недоступен')
    rescue RuntimeError => e
      puts e
      exit
    end

    choose_block.click
    find(:xpath, "//span[text()='Добавить блок']").click
    puts 'AD block was successfully created.'
  end

  private

  def choose_block
    find(:xpath, "//span[text()='#{@block_type}']")
  end

  def login_path
    "//span[text()='Войти']"
  end

  def path_after_login
    "//span[text()='#{@email}']"
  end
end

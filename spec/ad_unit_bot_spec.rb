require 'spec_helper'

RSpec.describe AdUnitBot do
  subject(:agent) { described_class.new(email, password, app_name, block_type) }

  after { Capybara.reset_sessions! }

  let(:email) { 'testmytestapp@yandex.ru' }
  let(:password) { '12345678d' }
  let(:app_name) { 'my-test-app.com' }
  let(:block_type) { 'standard' }
  before { stub_const('AdUnitBot::TARGET_URL', 'https://target-sandbox.my.com') }

  it 'connects to the site with valid data' do
    expect { agent.connect_to_site }.to_not raise_error
  end

  context 'with invalid data' do
    let(:password) { '123456' }

    it 'raises Sign In errors' do
      expect { agent.connect_to_site }.to raise_error(RuntimeError, 'Invalid login or password')
    end
  end

  it 'checks what the app present' do
    agent.connect_to_site

    expect(agent.app_present?).to be_truthy
  end

  context 'app dose not present' do
    let(:app_name) { 'sdfsdfsf.com' }

    it 'checks what app does not present' do
      agent.connect_to_site

      expect(agent.app_present?).to be_falsey
    end
  end

  it 'creates new app'
  it 'creates ad unit'
end

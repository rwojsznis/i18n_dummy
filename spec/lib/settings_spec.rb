require 'spec_helper'

describe "application settings" do
  before { reset_settings }
  after  { reset_settings }

  describe 'marker regex' do
    subject { I18nDummy::Settings.marker_regex }

    describe 'default' do
      it { should eq /U$/ }
    end

    describe 'from config' do
      before do
        I18nDummy::Settings.stub(:config).and_return({
          'marker' => { 'type' => 'prefix', 'symbol' => '+' }
        })
      end
      it { should eq /^\+/ }
    end
  end
end

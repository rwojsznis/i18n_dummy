require 'spec_helper'

describe 'preparing locale' do

  describe "basic example" do
    it_behaves_like "locale preparer", "basic"
  end

  describe "array example" do
    it_behaves_like "locale preparer", "array"
  end

  describe "quotes example" do
    it_behaves_like "locale preparer", "quotes"
  end

  describe "complicated example" do
    it_behaves_like "locale preparer", "complicated"
  end

  describe "locale with empty lines" do
    it_behaves_like "locale preparer", "empty_lines"
  end

  describe "using custom settings" do
    before do
      reset_settings
      I18nDummy::Settings.stub(:config).and_return({
        'marker' => { 'symbol' => '+', 'type' => 'prefix' }
      })
    end

    after  { reset_settings }

    it_behaves_like "locale preparer", "settings"
  end

end

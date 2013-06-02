require 'spec_helper'

describe "main page", :type => :feature do

  context "proper config" do
    before do
      Psych.stub(:load).and_return(
        :locale1 => { :base => 'base1', :polish => 'polish1' },
        :locale2 => { :base => 'base2', :polish => 'polish2' }
      )
      I18nDummy::Config.stub(:file_check).and_return(nil)
    end

    it "displays breadcrumb with configured locales" do
      visit "/"
      page.should have_css 'a', text: "locale1"
      page.should have_css 'a', text: "locale2"
    end
  end

  context "missing config" do
    before do
      I18nDummy::Config.stub(:exists?).and_return(false)
    end

    it "displays error message" do
      visit '/'
      page.should have_css '.alert-error', count: 1
      page.should have_content "Missing configuration"
    end
  end

  context "missing file from proper config" do
    before do
      # let the safe check pass
      Psych.stub(:load).and_return(
        :locale => { :base => '/home/user/base.yml', :polish => '/home/user/polish.yml' }
      )
      File.stub(:exists?).with('/home/user/base.yml').and_return(true)
    end

    it "displays error message" do
      visit '/'
      page.should have_content "Missing file: /home/user/polish.yml"
    end
  end

  context "missing base file" do
    before do
      Psych.stub(:load).and_return(
        :app => { :polish => 'polish' }
      )
      File.stub(:exists?).and_return(true)
    end

    it "displays error message" do
      visit '/'
      page.should have_content "Missing base locale for app"
    end
  end

end
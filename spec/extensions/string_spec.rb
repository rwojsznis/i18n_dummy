require 'spec_helper'

describe "string extensions" do

  describe "detecting marker" do
    subject { string.key_updated? }

    context "when with marker" do
      let(:string){ "this.is.my_updated_keyU" }
      it { should be_true }
    end

    context "when without marker" do
      let(:string){ "this.issomekeyforu" }
      it { should be_false }
    end
  end

  describe "removing marker" do
    subject { string.without_marker }

    context "when with marker" do
      let(:string){ "this.is.my_updated_keyU" }
      it { should eq("this.is.my_updated_key") }
    end

    context "when without marker" do
      let(:string){ "this.issomekeyforu" }
      it { should eq(string) }
    end
  end

  describe "removing quotes" do
    subject { string.dequote }

    context "string with double quotes" do
      let(:string){ '"look at me, ma\'!"'}
      it { should eq("look at me, ma'!") }
    end

    context "string with single quotes" do
      let(:string){ "'<a href=\"{url}\">click me!</a>'"}
      it { should eq('<a href="{url}">click me!</a>')}
    end
  end
end
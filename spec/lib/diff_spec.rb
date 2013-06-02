require 'spec_helper'

# TODO: fix those specs

describe 'Parser diff' do

  let(:file_pl) { "#{fixture_path}/diff/#{example}_pl.yml" }
  let(:file_en) { "#{fixture_path}/diff/#{example}_en.yml" }

  let(:parser_en) { I18nDummy::Parser::Base.new(file_en) }
  let(:parser_pl) { I18nDummy::Parser::Base.new(file_pl) }

  let(:diff)      { I18nDummy::Parser::Diff.new(parser_en, parser_pl) }

  subject { diff }

  context "no new nodes" do
    let(:example){ "no_new" }
    its(:any?)   { should be_false }
  end

  context "updated nodes" do
    let(:example){ "updated" }
    its(:any?)   { should be_true }

    it "returns updated nodes" do
      subject.new_nodes.map { |n| n.simple_values }.should eq([
        'Customer Support',
        'Sent with love',
        'Positions for all engines',
        'for the first 10 websites'
      ])
    end
  end

  context "added nodes" do
    let(:example){ "added" }
    its(:any?) { should be_true }

    it "returns updated nodes" do
      subject.new_nodes.map { |n| n.simple_values }.should eq([
        'this is new node',
        'You know it'
      ])
    end
  end

  context "added and updated nodes" do
    let(:example){ "both" }
    its(:any?){ should be_true }

    it "returns updated nodes" do
      subject.new_nodes.map { |n| n.simple_values }.should eq([
        "accumsan nisl",
        "Aenean imperdiet",
        "placerat",
        "odio",
        "Nulla facilisi"
      ])
    end
  end

end
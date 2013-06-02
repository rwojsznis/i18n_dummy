require 'spec_helper'

describe 'Dummy YAML parser' do

  let(:file_path){"#{fixture_path}/parser/#{file}" }
  let(:parser)   { I18nDummy::Parser::Base.new(file_path) }

  subject      { parser.parsed }

  describe "parsing correct yaml file" do
    let(:file) { "correct.yml" }

    context "starts with the root" do
      subject    { parser.parsed[0] }
      its(:key)  { should eq('en') }
      its(:path) { should eq([]) }
    end

    context "handles all the nodes" do
      subject    { parser.parsed }
      its(:size) { should eq(13) }
    end

    context "handles array values" do
      its([2])  { should have_node_count(3) }
      its([6])  { should have_node_count(3) }
      its([12]) { should have_node_count(1) }
    end

    context "handles comments" do
      subject { parser.parsed[index].value[value_index].comment }
      let(:value_index) { 0 }

      context "manually written" do
        let(:index) { 1 }
        it { should eq('Some random comments here, ay!') }
      end

      context "fixmes" do
        let(:index){ 4 }
        it { should eq('FIX ME') }
      end

      context "inside block values" do
        let(:index){ 6 }
        let(:value_index){ 2 }
        it { should eq('TODO') }
      end
    end

    context "removes quotes from the string" do
    end

    context "removes quotes from the string" do
      subject { parser.parsed[index] }

      context "for array values" do
        let(:index){ 6 }
        it { should have_node_content(0, "Don't you think?") }
        it { should have_node_content(1, "I know I do!") }
        it { should have_node_content(2, "Do you, really?") }
      end

      context "for regular values" do
        let(:index){ 4 }
        it { should have_node_content(0, "And I'm not") }
      end
    end

    context "saves correct path when" do
      subject { parser.parsed[index] }

      context "nested one level" do
        let(:index){ 7 }
        it { should have_node_key('key7')  }
        it { should have_node_path(%w(en)) }
      end

      context "nested two levels" do
        let(:index){ 8 }
        it { should have_node_key('key8')  }
        it { should have_node_path(%w(en key7)) }
      end

      context "nested three levels" do
        let(:index){ 9 }
        it { should have_node_key('key9')  }
        it { should have_node_path(%w(en key7 key8)) }
      end

      context "nested four levels" do
        let(:index){ 10 }
        it { should have_node_key('key10')  }
        it { should have_node_path(%w(en key7 key8 key9)) }
        it { should have_node_content(0, "U mad bro")}
      end

      context "nesting is reduced" do
        let(:index){ 11 }
        it { should have_node_key('key11')  }
        it { should have_node_path(%w(en key7)) }
        it { should have_node_content(0, "No, you mad!")}
      end
    end

    context "managing parsed yaml" do
      context "finding node by key" do
        subject { parser.find_by_path('key7.key8.key9.key10') }
        it { should have_node_content(0, "U mad bro") }
      end
    end

    it "tracks file line number" do
      [1, 2, 3, 7, 8, 9, 10,
       14, 15, 16, 17, 18].each_with_index do |line_number, index|
        parser.parsed[index].line.should eq(line_number)
      end
    end
  end

  describe "parsing yaml file with empty leafs" do
    let(:file){ "empty_leafs.yml" }

    context "ignores empty leafs" do
      subject { parser.parsed.size }
      it { should eq(8) }
    end

    context "handles nested keys that are mixed with empty ones" do
      subject { parser.parsed[6] }

      it { should have_node_content(0, "The end") }
      it { should have_node_path(%w(en key4 key5)) }
      it { should have_node_key('key8') }
    end

    it "tracks line number" do
      [1, 2, 3, 5, 6, 7, 10, 11].each_with_index do |line_number, index|
        parser.parsed[index].line.should eq(line_number)
      end
    end
  end

  describe "parsing incorrect yaml file" do
    let(:file){ "incorrect.yml" }

    it "raises an error on initialize" do
      expect { parser }.to raise_error(I18nDummy::Error, /Invalid syntax/)
    end
  end

  describe "parsing file with duplicate keys" do
    let(:file) { "duplicates.yml" }

    it "raises an error on initialize" do
      expect { parser }.to raise_error(I18nDummy::Error, /Duplicate key/)
    end
  end

  describe "parsing heavily nested file" do
    let(:file){ "nested.yml" }

    it "handles the nesting properly" do
      [['en', []],
       ['key1',  %w(en)],
       ['key2',  %w(en key1)],
       ['key3',  %w(en key1 key2)],
       ['key4',  %w(en key1 key2)],
       ['key5',  %w(en key1 key2)],
       ['key6',  %w(en key1)],
       ['key7',  %w(en key1)],
       ['key8',  %w(en key1 key7)],
       ['key9',  %w(en key1 key7)],
       ['key10', %w(en key1 key7)],
       ['key11', %w(en key1 key7 key10)],
       ['key12', %w(en key1 key7 key10)],
       ['key13', %w(en key1 key7 key10 key12)],
       ['key14', %w(en key1 key7 key10 key12)],
       ['key15', %w(en key1 key7 key10)],
       ['key16', %w(en key1 key7 key10 key15)],
       ['key17', %w(en key1 key7)],
       ['key18', %w(en key1 key7 key17)],
       ['key19', %w(en)],
       ['key20', %w(en key19)]].each_with_index do |val, idx|
        parser.parsed[idx].key.should eq(val[0])
        parser.parsed[idx].path.should eq(val[1])
      end
    end
  end

  describe "parsing file with duplicate key names (leafs only)" do
    let(:file){ "naming.yml" }

    it "does not raises an error on initialize" do
      expect { parser }.to_not raise_error(I18nDummy::Error, /Duplicate key/)
    end
  end

  # TODO: move to separate spec
  describe "writing updated keys in base locale" do
    let(:file){ "updated.yml" }
    let(:local_parser) { I18nDummy::Parser::Base.new("#{fixture_path}/parser/updated_pl.yml") }
    let!(:local_ready) { I18nDummy::Locale.prepare!(parser, local_parser) }

    context "rewrites key in base without adding fixme" do
      subject { parser.output.split("\n")[3] }
      it { should eq('  there: "there"') }
    end

    context "rewrites key in base without adding fixme after changing structure" do
      subject { parser.output.split("\n")[2] }
      it { should eq('    there: "as"') }
    end

    context "updates key in locale and adds fixme" do
      subject { local_ready.output.split("\n")[3] }
      it { should eq('  there: "there" # FIX ME') }
    end
  end

end
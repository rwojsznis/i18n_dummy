shared_examples "locale preparer" do |directory|

  let(:file_pl)     { "#{fixture_path}/#{directory}/pl.yml" }
  let(:file_en)     { "#{fixture_path}/#{directory}/en.yml" }
  let(:result_file) { "#{fixture_path}/#{directory}/result_pl.yml" }

  let(:parser_en) { I18nDummy::Parser::Base.new(file_en) }
  let(:parser_pl) { I18nDummy::Parser::Base.new(file_pl) }
  let(:prepared) { I18nDummy::Locale.prepare!(parser_en, parser_pl) }

  it "prepares proper locale" do
    result = I18nDummy::Parser::Base.new(result_file)
    prepared.parsed.should eq(result.parsed)
  end

  it "writes proper file" do
    prepared.output.should eq(File.read(result_file))
  end

end
# frozen_string_literal: true

RSpec.describe RelatonIana do
  before { RelatonIana.instance_variable_set :@configuration, nil }

  it "has a version number" do
    expect(RelatonIana::VERSION).not_to be nil
  end

  it "returs grammar hash" do
    hash = RelatonIana.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end

  it "get document" do
    VCR.use_cassette "auto-response-parameters" do
      bib = RelatonIana::IanaBibliography.get "IANA auto-response-parameters"
      xml = bib.to_xml bibdata: true
      file = "spec/fixtures/auto-response-parameters.xml"
      File.write file, xml, encoding: "UTF-8" unless File.exist? file
      expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
        .sub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}(?=<\/fetched>)/, Date.today.to_s)
      schema = Jing.new "grammars/relaton-iana-compile.rng"
      errors = schema.validate file
      expect(errors).to eq []
    end
  end

  it "not found document" do
    expect do
      bib = RelatonIana::IanaBibliography.get "IANA Link Relation Types"
      expect(bib).to be_nil
    end.to output(/\[relaton-iana\] \(IANA Link Relation Types\) not found/).to_stderr
  end
end

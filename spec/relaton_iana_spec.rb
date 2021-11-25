# frozen_string_literal: true

RSpec.describe RelatonIana do
  it "has a version number" do
    expect(RelatonIana::VERSION).not_to be nil
  end

  it "returs grammar hash" do
    hash = RelatonIana.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end

  it "get document" do
    VCR.use_cassette "service-names-port-numbers" do
      bib = RelatonIana::IanaBibliography.get "IANA service-names-port-numbers"
      xml = bib.to_xml bibdata: true
      file = "spec/fixtures/service-names-port-numbers.xml"
      File.write file, xml, encoding: "UTF-8" unless File.exist? file
      expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
        .sub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}(?=<\/fetched>)/, Date.today.to_s)
    end
  end
end

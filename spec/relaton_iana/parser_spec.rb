RSpec.describe RelatonIana::Parser do
  it "initialize" do
    expect(RelatonIana::Parser).to receive(:new).with(nil, nil).and_call_original
    expect(RelatonIana::Parser.parse(nil)).to be_nil
  end

  context "instance" do
    let(:xml) { Nokogiri::XML File.read("spec/fixtures/rpki.xml", encoding: "UTF-8") }

    subject do
      RelatonIana::Parser.new xml.at("/xmlns:registry"), nil
    end

    it "parse" do
      bib = subject.parse
      xml = bib.to_xml bibdata: true
      file = "spec/fixtures/rpki_bib.xml"
      File.write file, xml, encoding: "UTF-8" unless File.exist? file
      expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
    end

    it "replace slash in anchor" do
      doc = xml.at "/xmlns:registry"
      root_doc = RelatonIana::Parser.parse doc
      registry = doc.at "./xmlns:registry"
      parser = RelatonIana::Parser.new registry, root_doc
      expect(parser.anchor).to eq "RPKI__SIGNED-OBJECTS"
    end
  end
end

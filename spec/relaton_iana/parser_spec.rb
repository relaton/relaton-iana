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
  end
end

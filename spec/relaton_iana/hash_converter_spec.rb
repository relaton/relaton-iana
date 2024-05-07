describe RelatonIana::HashConverter do
  it "returns IanaBibliographicItem" do
    hash = {
      title: [{ content: "title" }],
    }
    item = described_class.bib_item(**hash)
    expect(item).to be_instance_of RelatonIana::IanaBibliographicItem
  end

  it "render YAML" do
    item = RelatonIana::XMLParser.from_xml File.read "spec/fixtures/auto-response-parameters.xml"
    hash = item.to_h
    file = "spec/fixtures/auto-response-parameters.yaml"
    File.write file, hash.to_yaml, encoding: "UTF-8" unless File.exist? file
    expect(hash).to eq YAML.load_file file
  end
end

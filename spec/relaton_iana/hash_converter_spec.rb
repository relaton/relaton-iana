describe RelatonIana::HashConverter do
  it "returns IanaBibliographicItem" do
    hash = {
      title: [{ content: "title" }],
    }
    item = described_class.bib_item(**hash)
    expect(item).to be_instance_of RelatonIana::IanaBibliographicItem
  end
end

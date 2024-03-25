RSpec.describe RelatonIana::DataFetcher do
  it "create output dir and run fetcher" do
    expect(FileUtils).to receive(:mkdir_p).with("dir")
    fetcher = double("fetcher")
    expect(fetcher).to receive(:fetch)
    expect(RelatonIana::DataFetcher)
      .to receive(:new).with("dir", "xml").and_return(fetcher)
    RelatonIana::DataFetcher.fetch output: "dir", format: "xml"
  end

  context "instance" do
    subject { RelatonIana::DataFetcher.new("dir", "bibxml") }
    let(:index) { subject.instance_variable_get(:@index) }

    it "initialize fetcher" do
      expect(subject.instance_variable_get(:@ext)).to eq "xml"
      expect(subject.instance_variable_get(:@files)).to eq []
      expect(subject.instance_variable_get(:@output)).to eq "dir"
      expect(subject.instance_variable_get(:@format)).to eq "bibxml"
      expect(index).to be_instance_of Relaton::Index::Type
      expect(subject).to be_instance_of(RelatonIana::DataFetcher)
    end

    context "fetch data" do
      before do
        expect(Dir).to receive(:[]).with("iana-registries/**/*.xml").and_return ["file.xml"]
        expect(index).to receive(:save)
      end

      it "successfully" do
        expect(File).to receive(:read).with("file.xml", encoding: "UTF-8").and_return("<registry></registry>")
        expect(subject).to receive(:parse).with("<registry></registry>")
        subject.fetch
      end

      it "warn when error" do
        expect(File).to receive(:read).with("file.xml", encoding: "UTF-8").and_raise(StandardError)
        expect { subject.fetch }.to output(/Error: StandardError\. File: file\.xml/).to_stderr_from_any_process
      end
    end

    it "parse" do
      content = File.read "spec/fixtures/rpki.xml", encoding: "UTF-8"
      expect(RelatonIana::Parser).to receive(:parse).with(Nokogiri::XML::Element).and_return :doc
      expect(subject).to receive(:save_doc).with(:doc)
      expect(RelatonIana::Parser).to receive(:parse).with(Nokogiri::XML::Element, :doc).and_return(:doc2).exactly(7).times
      expect(subject).to receive(:save_doc).with(:doc2).exactly(7).times
      subject.parse content
    end

    context "save doc" do
      it "skip" do
        expect(subject).not_to receive(:file_name)
        subject.save_doc nil
      end

      it "bibxml" do
        bib = double("bib", docnumber: "BIB")
        expect(bib).to receive(:to_bibxml).and_return("<xml/>")
        expect(File).to receive(:write)
          .with("dir/bib.xml", "<xml/>", encoding: "UTF-8")
        subject.save_doc bib
        expect(index.index).to eq [{ id: "BIB", file: "dir/bib.xml" }]
      end

      it "xml" do
        subject.instance_variable_set(:@format, "xml")
        bib = double("bib", docnumber: "BIB")
        expect(bib).to receive(:to_xml).with(bibdata: true).and_return("<xml/>")
        expect(File).to receive(:write)
          .with("dir/bib.xml", "<xml/>", encoding: "UTF-8")
        subject.save_doc bib
        expect(index.index).to eq [{ id: "BIB", file: "dir/bib.xml" }]
      end

      it "yaml" do
        subject.instance_variable_set(:@format, "yaml")
        subject.instance_variable_set(:@ext, "yaml")
        bib = double("bib", docnumber: "BIB")
        expect(bib).to receive(:to_hash).and_return({ id: 123 })
        expect(File).to receive(:write)
          .with("dir/bib.yaml", /id: 123/, encoding: "UTF-8")
        subject.save_doc bib
        expect(index.index).to eq [{ id: "BIB", file: "dir/bib.yaml" }]
      end

      it "warn when file exists" do
        subject.instance_variable_set(:@files, ["dir/bib.xml"])
        bib = double("bib", docnumber: "BIB")
        expect(bib).to receive(:to_bibxml).and_return("<xml/>")
        expect(File).to receive(:write)
          .with("dir/bib.xml", "<xml/>", encoding: "UTF-8")
        expect { subject.save_doc bib }
          .to output(/File dir\/bib.xml already exists/).to_stderr_from_any_process
        expect(index.index).to eq [{ id: "BIB", file: "dir/bib.xml" }]
      end
    end
  end

  # it do
  #   RelatonIana::DataFetcher.fetch format: "bibxml"
  # end
end

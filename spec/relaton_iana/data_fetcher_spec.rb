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

    it "initialize fetcher" do
      expect(subject.instance_variable_get(:@ext)).to eq "xml"
      expect(subject.instance_variable_get(:@files)).to eq []
      expect(subject.instance_variable_get(:@output)).to eq "dir"
      expect(subject.instance_variable_get(:@format)).to eq "bibxml"
      expect(subject).to be_instance_of(RelatonIana::DataFetcher)
    end

    context "fetch data" do
      before do
        resp = double body: '{"items":[{"path":"path/file.xml"}],"total_count":1}'
        expect(Faraday).to receive(:get).and_return resp
      end

      it "successfully" do
        resp = double code: "200", body: <<~XML
          <registry  xmlns='http://www.iana.org/assignments'>
            <registry></registry>
          </registry>
        XML
        uri = URI.join RelatonIana::DataFetcher::SOURCE, "path/file.xml"
        expect(Net::HTTP).to receive(:get_response).with(uri).and_return resp
        expect(RelatonIana::Parser).to receive(:parse).with(kind_of(Nokogiri::XML::Element)).and_return :bib
        expect(RelatonIana::Parser).to receive(:parse).with(kind_of(Nokogiri::XML::Element), :bib).and_return :bib
        expect(subject).to receive(:save_doc).with(:bib).twice
        subject.fetch
      end

      it "warn when error" do
        expect(Net::HTTP).to receive(:get_response).and_raise(StandardError)
        # expect(RelatonIana::Parser).to receive(:parse).and_raise(StandardError)
        expect { subject.fetch }.to output(/Error/).to_stderr
      end
    end

    it "use GITHUB_TOKEN" do
      expect(ENV).to receive(:[]).with("GITHUB_TOKEN").and_return("1234").twice
      allow(ENV).to receive(:[]).and_call_original
      resp = double body: '{"items":[],"total_count":0}'
      headers = { "Authorization" => "token 1234" }
      expect(Faraday).to receive(:get).with(kind_of(String), kind_of(Hash), headers).and_return resp
      subject.fetch
    end

    it "waite if rate limit is reached" do
      resp = double body: '{"message":"API rate limit exceeded"}'
      allow(Faraday).to receive(:get).and_return resp
      expect(subject).to receive(:sleep).with(30).exactly(3).times
      expect { subject.fetch }.to raise_error StandardError, "API rate limit exceeded"
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
      end

      it "xml" do
        subject.instance_variable_set(:@format, "xml")
        bib = double("bib", docnumber: "BIB")
        expect(bib).to receive(:to_xml).with(bibdata: true).and_return("<xml/>")
        expect(File).to receive(:write)
          .with("dir/bib.xml", "<xml/>", encoding: "UTF-8")
        subject.save_doc bib
      end

      it "yaml" do
        subject.instance_variable_set(:@format, "yaml")
        subject.instance_variable_set(:@ext, "yaml")
        bib = double("bib", docnumber: "BIB")
        expect(bib).to receive(:to_hash).and_return({ id: 123 })
        expect(File).to receive(:write)
          .with("dir/bib.yaml", /id: 123/, encoding: "UTF-8")
        subject.save_doc bib
      end

      it "warn when file exists" do
        subject.instance_variable_set(:@files, ["dir/bib.xml"])
        bib = double("bib", docnumber: "BIB")
        expect(bib).to receive(:to_bibxml).and_return("<xml/>")
        expect(File).to receive(:write)
          .with("dir/bib.xml", "<xml/>", encoding: "UTF-8")
        expect { subject.save_doc bib }
          .to output(/File dir\/bib.xml already exists/).to_stderr
      end
    end
  end

  # it do
  #   RelatonIana::DataFetcher.fetch format: "bibxml"
  # end
end

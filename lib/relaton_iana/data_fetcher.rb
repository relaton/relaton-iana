module RelatonIana
  class DataFetcher
    #
    # Data fetcher initializer
    #
    # @param [String] output directory to save files
    # @param [String] format format of output files (xml, yaml, bibxml)
    #
    def initialize(output, format)
      @output = output
      @format = format
      @ext = format.sub(/^bib/, "")
      @files = []
      @index = Relaton::Index.find_or_create :IANA, file: "index-v1.yaml"
    end

    #
    # Initialize fetcher and run fetch
    #
    # @param [Strin] output directory to save files, default: "data"
    # @param [Strin] format format of output files (xml, yaml, bibxml), default: yaml
    #
    def self.fetch(output: "data", format: "yaml")
      t1 = Time.now
      puts "Started at: #{t1}"
      FileUtils.mkdir_p output
      new(output, format).fetch
      t2 = Time.now
      puts "Stopped at: #{t2}"
      puts "Done in: #{(t2 - t1).round} sec."
    end

    #
    # Parse documents
    #
    def fetch
      Dir["iana-registries/**/*.xml"].each do |file|
        content = File.read file, encoding: "UTF-8"
        parse(content) if content.include? "<registry"
      rescue StandardError => e
        Util.error "Error: #{e.message}. File: #{file}"
      end
      @index.save
    end

    def parse(content)
      xml = Nokogiri::XML(content)
      registry = xml.at("/xmlns:registry")
      doc = Parser.parse registry
      save_doc doc
      registry.xpath("./xmlns:registry").each { |r| save_doc Parser.parse(r, doc) }
    end

    #
    # Save document to file
    #
    # @param [RelatonIana::IanaBibliographicItem, nil] bib bibliographic item
    #
    def save_doc(bib) # rubocop:disable Metrics/MethodLength
      return unless bib

      c = case @format
          when "xml" then bib.to_xml(bibdata: true)
          when "yaml" then bib.to_hash.to_yaml
          else bib.send("to_#{@format}")
          end
      file = file_name(bib)
      if @files.include? file
        Util.warn "File #{file} already exists. Document: #{bib.docnumber}"
      else
        @files << file
      end
      @index.add_or_update bib.docnumber, file
      File.write file, c, encoding: "UTF-8"
    end

    #
    # Generate file name
    #
    # @param [RelatonIana::IanaBibliographicItem] bib bibliographic item
    #
    # @return [String] file name
    #
    def file_name(bib)
      name = bib.docnumber.downcase.gsub(/[\s,:\/]/, "_").squeeze("_")
      File.join @output, "#{name}.#{@ext}"
    end
  end
end

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
      FileUtils.mkdir_p output unless Dir.exist? output
      new(output, format).fetch
      t2 = Time.now
      puts "Stopped at: #{t2}"
      puts "Done in: #{(t2 - t1).round} sec."
    end

    #
    # Parse documents
    #
    def fetch(page = 1) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      params = {
        q: "<registry repo:ietf-ribose/iana-registries extension:xml",
        page: page, per_page: 100
      }
      if ENV["GITHUB_TOKEN"]
        headers = { "Authorization" => "token #{ENV['GITHUB_TOKEN']}" }
      end
      attempt = 0
      json = {}
      until attempt > 3 || json["items"]
        if attempt.positive?
          warn "Rate limit is reached. Retrying in 30 sec."
          sleep 30
        end
        attempt += 1
        resp = Faraday.get "https://api.github.com/search/code", params, headers
        json = JSON.parse resp.body
      end
      raise StandardError, json["message"] if json["message"]

      json["items"].each do |item|
        fetch_doc URI.join(IanaBibliography::SOURCE, item["path"]).to_s
      end
      fetch(page + 1) if (json["total_count"] - (page * 100)).positive?
    end

    def fetch_doc(url)
      doc = Parser.parse url
      save_doc doc
    rescue StandardError => e
      warn "Error: #{e.message}. URL: #{url}"
    end

    #
    # Save document to file
    #
    # @param [RelatonW3c::W3cBibliographicItem, nil] bib bibliographic item
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
        warn "File #{file} already exists. Document: #{bib.docnumber}"
      else
        @files << file
      end
      File.write file, c, encoding: "UTF-8"
    end

    #
    # Generate file name
    #
    # @param [RelatonW3c::W3cBibliographicItem] bib bibliographic item
    #
    # @return [String] file name
    #
    def file_name(bib)
      name = bib.docnumber.gsub(/[\s,:\/]/, "_").squeeze("_")
      File.join @output, "#{name}.#{@ext}"
    end
  end
end

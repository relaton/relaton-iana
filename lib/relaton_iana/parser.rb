module RelatonIana
  class Parser
    #
    # Document parser initalization
    #
    # @param [Nokogiri::XML::Element] xml
    #
    def initialize(xml, rootdoc)
      @xml = xml
      @rootdoc = rootdoc
    end

    #
    # Initialize document parser and run it
    #
    # @param [Nokogiri::XML::Element] xml
    #
    # @return [RelatonIana::IanaBibliographicItem, nil] bibliographic item
    #
    def self.parse(xml, rootdoc = nil)
      new(xml, rootdoc).parse
    end

    #
    # Parse document
    #
    # @return [RelatonIana::IanaBibliographicItem, nil] bibliographic item
    #
    def parse # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      return unless @xml

      RelatonIana::IanaBibliographicItem.new(
        type: "standard",
        language: ["en"],
        script: ["Latn"],
        title: parse_title,
        link: parse_link,
        docid: parse_docid,
        docnumber: docnumber,
        date: parse_date,
        contributor: contributor,
      )
    end

    #
    # Parse title
    #
    # @return [RelatonBib::TypedTitleStringCollection] title
    #
    def parse_title
      content = @xml.at("./xmlns:title")&.text || @xml[:id]
      t = RelatonBib::TypedTitleString.new content: content
      RelatonBib::TypedTitleStringCollection.new [t]
    end

    #
    # Parse link
    #
    # @return [Array<RelatonBib::TypedUri>] link
    #
    def parse_link
      if @rootdoc then @rootdoc.link
      else
        uri = URI.join "https://www.iana.org/assignments/", @xml[:id]
        [RelatonBib::TypedUri.new(type: "self", content: uri.to_s)]
      end
    end

    #
    # Parse docidentifier
    #
    # @return [Arra<RelatonBib::DocumentIdentifier>] docidentifier
    #
    def parse_docid
      [RelatonBib::DocumentIdentifier.new(type: "IANA", id: pub_id, primary: true)]
    end

    #
    # Create anchor
    #
    # @return [String] anchor
    #
    def anchor
      docnumber.upcase.gsub("/", "__")
    end

    #
    # Generate PubID
    #
    # @return [String] PubID
    #
    def pub_id
      "IANA #{docnumber}"
    end

    #
    # Create docnumber
    #
    # @return [String] docnumber
    #
    def docnumber
      dn = ""
      dn += "#{@rootdoc.docnumber}/" if @rootdoc
      dn + @xml["id"]
    end

    #
    # Parse date
    #
    # @return [Array<RelatonBib::BibliographicDate>] date
    #
    def parse_date
      d = @xml.xpath("./xmlns:created|./xmlns:published|./xmlns:updated").map do |d|
        RelatonBib::BibliographicDate.new(type: d.name, on: d.text)
      end
      d.none? && @rootdoc ? @rootdoc.date : d
    end

    #
    # Create contributor
    #
    # @return [Array<RelatonBib::Contribution>] contributor
    #
    def contributor
      org = RelatonBib::Organization.new(
        name: "Internet Assigned Numbers Authority", abbreviation: "IANA",
      )
      role = { type: "publisher" }
      [RelatonBib::ContributionInfo.new(entity: org, role: [role])]
    end
  end
end

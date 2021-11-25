module RelatonIana
  class Parser
    #
    # Document parser initalization
    #
    # @param [String] url url
    #
    def initialize(url)
      resp = Net::HTTP.get_response URI(url)
      @xml = Nokogiri::XML(resp.body).at "/xmlns:registry" if resp.code == "200"
    end

    #
    # Initialize document parser and run it
    #
    # @param [String] url url
    #
    # @return [RelatonBib:BibliographicItem, nil] bibliographic item
    #
    def self.parse(url)
      new(url).parse
    end

    #
    # Parse document
    #
    # @return [RelatonBib:BibliographicItem, nil] bibliographic item
    #
    def parse # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      return unless @xml

      RelatonBib::BibliographicItem.new(
        type: "standard",
        fetched: Date.today.to_s,
        language: ["en"],
        script: ["Latn"],
        title: parse_title,
        link: parse_link,
        docid: parse_docid,
        docnumber: @xml["id"],
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
      t = RelatonBib::TypedTitleString.new content: @xml.at("./xmlns:title").text
      RelatonBib::TypedTitleStringCollection.new [t]
    end

    #
    # Parse link
    #
    # @return [Array<RelatonBib::TypedUri>] link
    #
    def parse_link
      uri = URI.join @xml.namespace.href.sub(/(?<=[^\/])$/, "/"), @xml[:id]
      [RelatonBib::TypedUri.new(type: "src", content: uri.to_s)]
    end

    #
    # Parse docidentifier
    #
    # @return [Arra<RelatonBib::DocumentIdentifier>] docidentifier
    #
    def parse_docid
      [RelatonBib::DocumentIdentifier.new(type: "IANA", id: pub_id)]
    end

    #
    # Generate PubID
    #
    # @return [String] PubID
    #
    def pub_id
      "IANA #{@xml[:id]}"
    end

    #
    # Parse date
    #
    # @return [Array<RelatonBib::BibliographicDate>] date
    #
    def parse_date
      @xml.xpath("./xmlns:created|./xmlns:published|./xmlns:updated").map do |d|
        RelatonBib::BibliographicDate.new(type: d.name, on: d.text)
      end
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

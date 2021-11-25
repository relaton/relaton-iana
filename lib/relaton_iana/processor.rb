require "relaton/processor"

module RelatonIana
  class Processor < Relaton::Processor
    attr_reader :idtype

    def initialize # rubocop:disable Lint/MissingSuper
      @short = :relaton_iana
      @prefix = "IANA"
      @defaultprefix = %r{^IANA\s}
      @idtype = "IANA"
      @datasets = %w[iana-registries]
    end

    # @param code [String]
    # @param date [String, NilClass] year
    # @param opts [Hash]
    # @return [RelatonBib::BibliographicItem]
    def get(code, date, opts)
      ::RelatonIana::IanaBibliography.get(code, date, opts)
    end

    #
    # Fetch all the documents from https://github.com/ietf-ribose/iana-registries
    #
    # @param [String] _source source name
    # @param [Hash] opts
    # @option opts [String] :output directory to output documents
    # @option opts [String] :format
    #
    def fetch_data(_source, opts)
      DataFetcher.fetch(**opts)
    end

    # @param xml [String]
    # @return [RelatonBib::BibliographicItem]
    def from_xml(xml)
      ::RelatonBib::XMLParser.from_xml xml
    end

    # @param hash [Hash]
    # @return [RelatonIana::BibliographicItem]
    def hash_to_bib(hash)
      item_hash = ::RelatonBib::HashConverter.hash_to_bib(hash)
      ::RelatonWBib::BibliographicItem.new(**item_hash)
    end

    # Returns hash of XML grammar
    # @return [String]
    def grammar_hash
      @grammar_hash ||= ::RelatonIana.grammar_hash
    end
  end
end

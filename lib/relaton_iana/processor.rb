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
    # @return [RelatonIana::IanaBibliographicItem]
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
    # @return [RelatonIana::IanaBibliographicItem]
    def from_xml(xml)
      ::RelatonIana::XMLParser.from_xml xml
    end

    # @param hash [Hash]
    # @return [RelatonIana::IanaBibliographicItem]
    def hash_to_bib(hash)
      item_hash = ::RelatonIana::HashConverter.hash_to_bib(hash)
      ::RelatonIana::IanaBibliographicItem.new(**item_hash)
    end

    # Returns hash of XML grammar
    # @return [String]
    def grammar_hash
      @grammar_hash ||= ::RelatonIana.grammar_hash
    end

    #
    # Remove index file
    #
    def remove_index_file
      Relaton::Index.find_or_create(:IANA, url: true, file: IanaBibliography::INDEX_FILE).remove_file
    end
  end
end

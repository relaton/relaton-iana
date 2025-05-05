# frozen_string_literal: true

require "faraday"
require "relaton/index"
require "relaton/bib"
require_relative "iana/version"
require_relative "iana/util"
require_relative "iana/item"
require_relative "iana/bibitem"
require_relative "iana/bibdata"
# require_relative "relaton_iana/xml_parser"
# require_relative "relaton_iana/hash_converter"
# require_relative "relaton_iana/iana_bibliography"
# require_relative "relaton_iana/parser"
# require_relative "relaton_iana/data_fetcher"

module Relaton
  module Iana
    class Error < StandardError; end

    # Returns hash of XML reammar
    # @return [String]
    def self.grammar_hash
      # gem_path = File.expand_path "..", __dir__
      # grammars_path = File.join gem_path, "grammars", "*"
      # grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
      Digest::MD5.hexdigest Relaton::Iana::VERSION + Relaton::Bib::VERSION # grammars
    end
  end
end

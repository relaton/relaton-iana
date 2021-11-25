# frozen_string_literal: true

require "net/http"
require "relaton_bib"
require_relative "relaton_iana/version"
require_relative "relaton_iana/iana_bibliography"
require_relative "relaton_iana/parser"
require_relative "relaton_iana/data_fetcher"

module RelatonIana
  class Error < StandardError; end

  # Returns hash of XML reammar
  # @return [String]
  def self.grammar_hash
    gem_path = File.expand_path "..", __dir__
    grammars_path = File.join gem_path, "grammars", "*"
    grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
    Digest::MD5.hexdigest grammars
  end
end

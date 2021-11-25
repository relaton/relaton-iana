# frozen_string_literal: true

module RelatonIana
  # Methods for search IANA standards.
  module IanaBibliography
    SOURCE = "https://raw.githubusercontent.com/ietf-ribose/iana-registries/main/"

    # @param text [String]
    # @return [RelatonBib::BibliographicItem]
    def search(text) # rubocop:disable Metrics/MethodLength
      file = text.sub(/^IANA\s/, "")
      url = "#{SOURCE}#{file}/#{file}.xml"
      Parser.parse url
    rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
           EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
           Net::ProtocolError, Errno::ETIMEDOUT => e
      raise RelatonBib::RequestError, e.message
    end

    # @param ref [String] the W3C standard Code to look up
    # @param year [String, NilClass] not used
    # @param opts [Hash] options
    # @return [RelatonBib::BibliographicItem]
    def get(ref, _year = nil, _opts = {})
      warn "[relaton-iana] (\"#{ref}\") fetching..."
      result = search(ref)
      return unless result

      warn "[relaton-iana] (\"#{ref}\") found #{result.docidentifier[0].id}"
      result
    end

    extend IanaBibliography
  end
end

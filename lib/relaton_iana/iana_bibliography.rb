# frozen_string_literal: true

module RelatonIana
  # Methods for search IANA standards.
  module IanaBibliography
    SOURCE = "https://raw.githubusercontent.com/relaton/relaton-data-iana/main/"
    INDEX_FILE = "index-v1.yaml"

    # @param text [String]
    # @return [RelatonIana::IanaBibliographicItem]
    def search(text) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      # file = text.sub(/^IANA\s/, "").gsub(/[\s,:\/]/, "_").downcase
      # url = "#{SOURCE}#{file}.yaml"
      index = Relaton::Index.find_or_create :IANA, url: "#{SOURCE}index-v1.zip", file: INDEX_FILE
      id = text.sub(/^IANA\s/, "")
      row = index.search(id).min_by { |i| i[:id] }
      return unless row

      url = "#{SOURCE}#{row[:file]}"
      resp = Net::HTTP.get_response URI(url)
      return unless resp.code == "200"

      hash = YAML.safe_load resp.body
      hash["fetched"] = Date.today.to_s
      IanaBibliographicItem.from_hash hash
    rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
           EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
           Net::ProtocolError, Errno::ETIMEDOUT => e
      raise RelatonBib::RequestError, e.message
    end

    # @param ref [String] the W3C standard Code to look up
    # @param year [String, NilClass] not used
    # @param opts [Hash] options
    # @return [RelatonIana::IanaBibliographicItem]
    def get(ref, _year = nil, _opts = {})
      Util.info "Fetching from Relaton repository ...", key: ref
      result = search(ref)
      unless result
        Util.info "Not found.", key: ref
        return
      end

      Util.info "Found: `#{result.docidentifier[0].id}`", key: ref
      result
    end

    extend IanaBibliography
  end
end

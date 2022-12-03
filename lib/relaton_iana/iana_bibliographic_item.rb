module RelatonIana
  # IANA Bibliographic Item
  class IanaBibliographicItem < RelatonBib::BibliographicItem
    #
    # Fetch flavor schema version
    #
    # @return [String] flavor schema version
    #
    def ext_schema
      @ext_schema ||= schema_versions["relaton-model-iana"]
    end
  end
end

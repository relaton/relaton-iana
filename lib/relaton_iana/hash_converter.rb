module RelatonIana
  class HashConverter < RelatonBib::HashConverter
    # @param item_hash [Hash]
    # @return [RelatonIana::IanaBibliographicItem]
    def self.bib_item(item_hash)
      IanaBibliographicItem.new(**item_hash)
    end
  end
end

module RelatonIana
  module HashConverter
    include RelatonBib::HashConverter
    extend self

    # @param item_hash [Hash]
    # @return [RelatonIana::IanaBibliographicItem]
    def bib_item(item_hash)
      IanaBibliographicItem.new(**item_hash)
    end
  end
end

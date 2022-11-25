module RelatonIana
  # IANA Bibliographic Item
  class IanaBibliographicItem < RelatonBib::BibliographicItem
    #
    # Render BubXML date. Overridden to remove date.
    #
    # @param builder [Nokogiri::XML::Builder]
    #
    # def render_date(builder); end
  end
end

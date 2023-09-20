module RelatonIana
  module Util
    extend RelatonBib::Util

    def self.logger
      RelatonIana.configuration.logger
    end
  end
end

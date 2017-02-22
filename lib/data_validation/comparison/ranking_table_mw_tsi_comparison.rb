require 'data_validation/comparison/comparison_base'

module DataValidation
  module Comparison
    class RankingTableMwTsiComparison < ComparisonBase

      def api_path
        '/rest/LaxPower/rankingTableMWtsi'
      end

      def field_array
        ['rank', 'teamName', 'tsi', 'pollRank', 'prRank', 'rpiRank', 'sosRank', 'qwf', 'loss', 'trend', %w|record wins|, %w|record losses|, %w|record ties|]
      end

      def empty_field
        'pollRank'
      end

    end
  end
end
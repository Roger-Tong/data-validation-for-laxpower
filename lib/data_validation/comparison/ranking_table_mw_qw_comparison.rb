require 'data_validation/comparison/comparison_base'

module DataValidation
  module Comparison
    class RankingTableMwQwComparison < ComparisonBase

      def api_path
        '/rest/LaxPower/rankingTableMWqw'
      end

      def field_array
        ['rank', 'teamName', 'qwPrRank', 'qualityWinsPr', nil, 'qualityWinsPoll', 'qwRpiRank', 'qualityWinsRpi', %w|record wins|, %w|record losses|, %w|record ties|]
      end

    end
  end
end
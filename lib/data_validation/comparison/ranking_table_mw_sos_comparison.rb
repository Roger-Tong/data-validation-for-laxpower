require 'data_validation/comparison/comparison_base'

module DataValidation
  module Comparison
    class RankingTableMwSosComparison < ComparisonBase

      def api_path
        '/rest/LaxPower/rankingTableMWsos'
      end

      def field_array
        ['rank', 'teamName', 'totalGames', nil,  'sosAverage', 'sosWeightedRank', 'sosWeighted', 'sosRpiRank', 'sosRpi', %w|record wins|, %w|record losses|, %w|record ties|]
      end

    end
  end
end
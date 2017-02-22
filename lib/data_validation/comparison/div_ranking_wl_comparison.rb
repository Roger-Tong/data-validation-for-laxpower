require 'data_validation/comparison/comparison_base'

module DataValidation
  module Comparison
    class DivRankingWlComparison < ComparisonBase

      def api_path
        '/rest/LaxPower/divisionRankingWl'
      end

      def field_array
        ['rank', 'teamName', 'rank', 'winLossTotal', 'rankDivision', 'winLossDivision', 'rankDate', 'winLossDate', 'rankRoad', 'winLossRoad', %w|record wins|, %w|record losses|, %w|record ties|]
      end

     end
  end
end
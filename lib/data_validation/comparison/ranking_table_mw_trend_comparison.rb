require 'data_validation/comparison/comparison_base'

module DataValidation
  module Comparison
    class RankingTableMwTrendComparison < ComparisonBase

      def api_path
        '/rest/LaxPower/rankingTableMWtrend
'
      end

      def field_array
        ['rank', 'teamName', %w|record wins|, %w|record losses|, %w|record ties|, 'trend']
      end

    end
  end
end
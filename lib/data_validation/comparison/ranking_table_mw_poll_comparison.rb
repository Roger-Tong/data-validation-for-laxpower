require 'data_validation/comparison/comparison_base'

module DataValidation
  module Comparison
    class RankingTableMwPollComparison < ComparisonBase

      def api_path
        '/rest/LaxPower/rankingTableMWpoll'
      end

      def field_array
        ['rank', 'teamName', %w|record wins|, %w|record losses|, %w|record ties|, 'pollPoint', 'pollFirst', 'lastWeek']
      end

      def empty_field
        'pollFirst'
      end

    end
  end
end
require 'data_validation/comparison/comparison_base'

module DataValidation
  module Comparison
    class RankingTableMwRpiComparison < ComparisonBase

      def api_path
        '/rest/LaxPower/rankingTableMWrpi'
      end

      def field_array
        ['rank', 'teamName', nil, 'rpi', 'signWinsRank', 'signficantWins', 'signLossRank', 'signficantLosses',
         %w|recordTotal wins|, %w|recordTotal losses|, %w|recordTotal ties|,
         %w|recordRoad wins|, %w|recordRoad losses|, %w|recordRoad ties|,
         %w|recordNeutral wins|, %w|recordNeutral losses|, %w|recordNeutral ties|,
         %w|recordHome wins|, %w|recordHome losses|, %w|recordHome ties|]
      end

    end
  end
end
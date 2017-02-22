require 'data_validation/comparison/div_ranking_pr_comparison'
require 'data_validation/comparison/ranking_table_mw_sos_comparison'
require 'data_validation/comparison/ranking_table_mw_rpi_comparison'
require 'data_validation/comparison/div_ranking_wl_comparison'
require 'data_validation/comparison/ranking_table_mw_qw_comparison'
require 'data_validation/comparison/ranking_table_mw_poll_comparison'
require 'data_validation/comparison/ranking_table_mw_trend_comparison'
require 'data_validation/comparison/ranking_table_mw_tsi_comparison'
require 'data_validation/comparison/ranking_table_mw_pr_comparison'

module DataValidation
  module Comparison
    class ComparisonFactory
      def self.get_comparison(url)
        if url.match /update\d\d\/bin(boy|grl)\/rating\d+.php/ # division Computer Rating page for boys/girls
          return DivRankingPrComparison.new url
        elsif url.match /update\d\d\/bin\S+\/rating\d+.php/ # division Computer Rating page for men and women
          return RankingTableMwPrComparison.new url
        elsif url.match /update\d\d\/bin\S+\/sos\d+.php/ # division Strength of Schedule page for boys/girls
          return RankingTableMwSosComparison.new url
        elsif url.match /update\d\d\/bin\S+\/rpi\d+.php/ # division RPI Rankings page for boys/girls
          return RankingTableMwRpiComparison.new url
        elsif url.match /update\d\d\/bin\S+\/wl\d+.php/ # division win-loss factor page for boys/girls
          return DivRankingWlComparison.new url
        elsif url.match /update\d\d\/bin\S+\/qwf\d+.php/ # division Quality Win Factor page for boys/girls
          return RankingTableMwQwComparison.new url
        elsif url.match /update\d\d\/bin\S+\/poll\d+.php/ # Poll page for collage division
          return RankingTableMwPollComparison.new url
        elsif url.match /update\d\d\/bin\S+\/trend\d+.php/ # Trend page for collage division
          return RankingTableMwTrendComparison.new url
        elsif url.match /update\d\d\/bin\S+\/tsi\d+.php/ # Trend page for collage division
          return RankingTableMwTsiComparison.new url
        end
      end
    end
  end
end

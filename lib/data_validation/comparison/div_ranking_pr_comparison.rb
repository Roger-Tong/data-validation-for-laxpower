require 'data_validation/comparison/comparison_base'

module DataValidation
  module Comparison
    class DivRankingPrComparison < ComparisonBase

      def api_path
        '/rest/LaxPower/divisionRankingPr'
      end

      def field_array
        ['rank', 'teamName', 'powerRating', 'regInPr', 'correction', 'championship', 'winLossTotal', %w|record wins|, %w|record losses|, %w|record ties|]
      end

      def empty_field
        ''
      end

      def compare

        data_access = DataValidation::DataAccess.new(web_url, DataValidation.api_request_host + api_path, determine_request_body_and_logger_name)

        puts 'requesting web page...'
        web_data = data_access.get_main_table_data
        puts 'requesting mobile api data: ' + DataValidation.api_request_host + api_path
        api_data = data_access.get_response_from_mobile_api

        if web_data.length != api_data['results']['results']['total']
          logger.error "The record size between web page and api data is not the same: #{web_data.length} -- #{api_data['results']['results']['total']}"
          return
        end

        ## compare first table
        web_data.each_with_index do |item, index|
          team = api_data['results']['results']['teams'][index]

          i = 0
          field_array.each do |filed_name|

            if filed_name.is_a? String
              team_value = team[filed_name]
            elsif filed_name.is_a? Array
              team_value = team[filed_name[0]][filed_name[1]]
            else
              next
            end

            if item.length < field_array.length && empty_field && empty_field == filed_name ## when the field is possibly empty in the table
              logger.error "team #{item[0]}'s #{filed_name} is not empty: #{team_value}" unless (team_value == 0 || team_value.nil?)
              next
            end


            unless (team_value.is_a?(String) && team_value.include?(item[i])) ||
              (team_value.is_a?(Float) && team_value == item[i].to_f) ||
              (team_value.is_a?(Integer) && team_value == item[i].to_i)

              logger.error "team #{item[0]}'s #{filed_name} is not correct: #{item[i]} -- #{team_value}"
            end

            i += 1
          end

        end

        ## compare standing tables
        compare_conf_standings(api_data, data_access)
      end



      def conf_rank_api_url
        DataValidation.api_request_host + '/rest/LaxPower/conferenceRankingTable'
      end

    end
  end
end
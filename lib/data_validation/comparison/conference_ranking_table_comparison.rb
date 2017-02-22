require 'data_validation/comparison/comparison_base'

module DataValidation
  module Comparison
    class RankingTableMwPollComparison < ComparisonBase

      def compare

        if api_path.nil?
          raise 'Please define api_path'
        end

        data_access = DataValidation::DataAccess.new(web_url, DataValidation.api_request_host + api_path, determine_request_body_and_logger_name)

        puts 'requesting web page...'
        web_data = data_access.get_main_table_data
        puts 'requesting mobile api data: ' + DataValidation.api_request_host + api_path
        api_data = data_access.get_response_from_mobile_api

        if web_data.length != api_data['results']['results']['total']
          logger.error "The record size between web page and api data is not the same: #{web_data.length} -- #{api_data['results']['results']['total']}"
          return
        end

        web_data.each_with_index do |item, index|
          team = api_data['results']['results']['teams'][index]

          field_array.each_with_index do |filed_name, index|
            if filed_name.is_a? String
              team_value = team[filed_name]
            elsif filed_name.is_a? Array
              team_value = team[filed_name[0]][filed_name[1]]
            else
              next
            end

            unless (team_value.is_a?(String) && team_value.include?(item[index])) ||
              (team_value.is_a?(Float) && team_value == item[index].to_f) ||
              (team_value.is_a?(Integer) && team_value == item[index].to_i)

              logger.error "team #{item[0]}'s #{filed_name} is not correct: #{item[index]} -- #{team_value}"
            end
          end

        end
      end

    end
  end

  def determine_request_body_and_logger_name
    category = if web_url.match /bingrl/
                 'GIRLS'
               elsif web_url.match /binboy/
                 'BOYS'
               elsif web_url.match /binmen/
                 'MEN'
               elsif web_url.match /binwom/
                 'WOMEN'
               end

    season = "20#{web_url.match(/update(..)/)[1]}"

    division_id = web_url.match(/(\d+)\.php/)[1].to_i

    operation = web_url.match(/\/([a-z]+)\d+.php/)[1]

    @logger_name = "log/#{season}/#{category.downcase}/#{operation}/#{operation}_#{season}_#{category}_#{division_id}.log"

    %Q|{"season":"#{season}", "conference": {"category": "#{category}",} "divisionId":#{division_id},"currPage":1,"pageSize":1000}|
  end
end
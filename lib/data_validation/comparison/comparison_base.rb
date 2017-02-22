require 'data_validation/data_access'
require 'logger'

module DataValidation
  module Comparison
    class ComparisonBase
      attr_reader :web_url, :logger_name, :category, :season, :division_id

      def initialize(web_url)
        @web_url = web_url
      end

      def compare
        if api_path.nil?
          raise 'Please define api_path'
        end

        if field_array.nil?
          raise 'Please define field_array'
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

          i = 0
          field_array.each do |filed_name|

            if filed_name.is_a? String
              team_value = team[filed_name]
            elsif filed_name.is_a? Array
              team_value = team[filed_name[0]][filed_name[1]]
            else
              i += 1
              next
            end

            if item.length < field_array.length && empty_field && empty_field == filed_name ## when the field is empty in the table
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
      end

      def compare_conf_standings(api_data, data_access)
        puts 'Start to compare conf ranking tables'
        conf_standing_data = data_access.conf_standing_data
        conf_standing_data.each do |standing|
          full_conf = ''
          # puts standing.to_s
          standing.each_with_index do |record, i|
            if i == 0
              state = record[0]
              team_class = record[1]
              conf = record[2]
              full_conf = "#{state}, #{team_class}, #{conf}"

              api_data = data_access.get_response_from_mobile_api_with_params(conf_rank_api_url, %Q|{"season": "#{season}", "conference": {"category": "#{category}", "conference": "#{conf}", "divisionId": #{division_id.to_i}, "state": "#{state}", "teamClass": "#{team_class}"}, "currPage": 1, "pageSize": 1000}|)

              if api_data['results']['results']['total'] != standing.length - 1
                logger.error "standing for #{full_conf} has incorrect length: #{standing.length - 1} : #{api_data['results']['results']['total']}"
                break
              end
            else

              team_data = api_data['results']['results']['teams'][i - 1]

              record.each_with_index do |item, index|
                if index == 0 && item.to_i != team_data['rank']
                elsif index == 1 && item.to_f != team_data['powerRating']
                  logger.error "team #{i} has incorrect powerRating in #{full_conf}: #{item.to_f} -- #{team_data['powerRating']}"
                elsif index == 2 && item.to_i != team_data['conference']['wins']
                  logger.error "team #{i} has incorrect conference wins in #{full_conf}: #{item.to_i} -- #{team_data['conference']['wins']}"
                elsif index == 3 && item.to_i != team_data['conference']['losses']
                  logger.error "team #{i} has incorrect conference losses in #{full_conf}: #{item.to_i} -- #{team_data['conference']['losses']}"
                elsif index == 4 && item.to_i != team_data['conference']['ties']
                  logger.error "team #{i} has incorrect conference ties in #{full_conf}: #{item.to_i} -- #{team_data['conference']['ties']}"
                elsif index == 5 && item.to_f != team_data['winLossConf']
                  logger.error "team #{i} has incorrect winLossConf in #{full_conf}: #{item.to_f} -- #{team_data['winLossConf']}"
                elsif index == 6 && item.to_i != team_data['total']['wins']
                  logger.error "team #{i} has incorrect total wins in #{full_conf}: #{item.to_i} -- #{team_data['total']['wins']}"
                elsif index == 7 && item.to_i != team_data['total']['losses']
                  logger.error "team #{i} has incorrect total losses in #{full_conf}: #{item.to_i} -- #{team_data['total']['losses']}"
                elsif index == 8 && item.to_i != team_data['total']['ties']
                  logger.error "team #{i} has incorrect total ties in #{full_conf}: #{item.to_i} -- #{team_data['total']['ties']}"
                elsif index == 9 && item.to_f != team_data['winLossTotal']
                  logger.error "team #{i} has incorrect winLossTotal in #{full_conf}: #{item.to_f} -- #{team_data['winLossTotal']}"
                end
              end
            end

          end
        end
      end

      protected

      def api_path

      end

      def field_array

      end

      def empty_field

      end

      private

      def logger
        @logger ||= begin
                      tokens = logger_name.split('/')
                      1.upto(tokens.size - 1) do |n|
                        dir = tokens[0...n].join('/')
                        Dir.mkdir(dir) unless Dir.exist?(dir)
                      end
                      Logger.new File.new(logger_name, 'w')
        end
      end

      def determine_request_body_and_logger_name
        @category = if web_url.match /bingrl/
                     'GIRLS'
                   elsif web_url.match /binboy/
                     'BOYS'
                   elsif web_url.match /binmen/
                     'MEN'
                   elsif web_url.match /binwom/
                     'WOMEN'
                   end

        @season = "20#{web_url.match(/update(..)/)[1]}"

        @division_id = web_url.match(/(\d+)\.php/)[1].to_i

        operation = web_url.match(/\/([a-z]+)\d+.php/)[1]

        @logger_name = "log/#{season}/#{category.downcase}/#{operation}/#{operation}_#{season}_#{category}_#{division_id}.log"

        %Q|{"category":"#{category}","season":#{season},"divisionId":#{division_id},"currPage":1,"pageSize":1000}|
      end
    end
  end
end

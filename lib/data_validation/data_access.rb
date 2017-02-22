require 'nokogiri'
require 'httparty'
require 'open-uri'

module DataValidation
  class DataAccess

    attr_reader :html_url, :api_url, :api_body, :conf_standing_data

    def initialize(html_url, api_url, api_body)
      @html_url = html_url
      @api_url = api_url
      @api_body = api_body
    end

    def get_main_table_data
      doc = Nokogiri::HTML(open(html_url))

      if html_url.match /rating/
        extract_conf_standing_data(doc)
      end

      team_names = doc.search('div.cs1 div.cs1 a').map { |node| node.text if /^[A-Z\d]+.PHP$/.match(node.attr('href')) }.compact ## extract team names

      doc.search('div.cs1 div.cs1 a').remove ## then remove all links from the doc

      index = 0
      doc.search('div.cs1 div.cs1').text.lines.map do |line|
        if /^\s*(?<rank>\d+)\s+(?<rest>.*)/ =~ line
          data_array = ([rank] << team_names[index]) + rest.split(' ')
          index += 1
          data_array
        end
      end.compact
    end

    def extract_conf_standing_data(doc)
      category = if html_url.match /bingrl/
                   'GIRLS'
                 elsif html_url.match /binboy/
                   'BOYS'
                 elsif html_url.match /binmen/
                   'MEN'
                 elsif html_url.match /binwom/
                   'WOMEN'
                 end

      season = "20#{html_url.match(/update(..)/)[1]}"

      div_id = html_url.match(/(\d+)\.php/)[1].to_i

      conf_data = get_conference(season, category, div_id)['results']['results']['conferences']

      # is_for_mw_pr = html_url.include?('binmen') || html_url.include?('binwomen')

      ## only rating page has conf standing tables
      doc.search('div.laxcss a').remove ## remove team names from conf standing tables
      @conf_standing_data = []
      conf_standing_record = []
      lines = doc.search('div.laxcs1, div.laxcss').text.lines

      conf_data_index = 0
      lines.each_with_index do |line, index|
        if line.match /^\s[A-Z]/
          if conf_standing_record.length > 0 ## it's a new conf standing table
            @conf_standing_data << conf_standing_record
            conf_standing_record = []
          end

          conf = conf_data[conf_data_index]

          if conf.nil?
            puts 'No independent conf data'
            @conf_standing_data << conf_standing_record
            break
          end

          conf_standing_record << [conf['state'], conf['teamClass'], conf['conference']]

          conf_data_index += 1
        elsif /^\s*\d+\s+/.match line
          conf_standing_record << line.split(' ')
        end

        if (index == lines.length - 1)
          @conf_standing_data << conf_standing_record
        end
      end
    end

    def get_response_from_mobile_api
      HTTParty.post(api_url, headers: {'Content-Type' => 'application/json'}, body: api_body)
    end

    def get_response_from_mobile_api_with_params(url, body)
      HTTParty.post(url, headers: {'Content-Type' => 'application/json'}, body: body)
    end

    def get_conference(season, category, div_id)
      puts "get conference data for #{season}, #{category}, #{div_id} from " + DataValidation.api_request_host + '/rest/LaxPower/getConferences'
      HTTParty.post(DataValidation.api_request_host + '/rest/LaxPower/getConferences',
                    headers: {'Content-Type' => 'application/json'},
                    body: %Q|{"season": "#{season}","category": "#{category}", "divisionId": #{div_id}}|)
    end

    def self.get_high_school_div_stat_urls(season='17', category='boys')
      is_for_hs = category == 'boys' || category == 'girls'
      high_school_div_stat_main_url = if is_for_hs
                                        "#{DataValidation.web_request_host}/common/hs_#{category}.php"
                                      else
                                        "#{DataValidation.web_request_host}/common/college_#{category}.php"
                                      end
      doc = Nokogiri::HTML(open(high_school_div_stat_main_url))
      urls = doc.search('div#content_well a[href*=rating]').map do |item|
        href = item.attr('href')
        if href.match /rating\d\d/
          href.sub!('..', DataValidation.web_request_host)
          href.sub!('update17', "update#{season}") if season!= '17'
          href
        end
      end.compact

      final_urls = [] + urls
      ## append other metrics e.g. sos, rpi
      if is_for_hs
        %w|sos rpi wl qwf|.each { |stat_name| final_urls += replace_with_stat_name(urls, stat_name) }
      else
        %w|tsi poll rpi sos qwf trend|.each { |stat_name| final_urls += replace_with_stat_name(urls, stat_name) }
      end
      puts "totally #{final_urls.length} urls for #{season}, #{category}"
      final_urls
    end

    def self.replace_with_stat_name urls, stat_name
      urls.map do |url|
        url.sub 'rating', stat_name
      end
    end
  end
end

require 'data_validation/comparison/comparison_factory'
require 'data_validation/data_access'
require 'yaml'

module DataValidation
  class << self

    def web_request_host
      @web_request_host ||= begin
        YAML.load_file('config/hosts.yml')['prod']['web_request_host']
      end
    end

    def api_request_host
      @api_request_host ||= begin
        YAML.load_file('config/hosts.yml')['prod']['api_request_host']
      end
    end

    def configure_with_env(env)
      yaml_config = YAML.load_file('config/hosts.yml')
      hash_config = yaml_config[env]
      @web_request_host = hash_config['web_request_host']
      @api_request_host = hash_config['api_request_host']
    end

    def compare_with_season_and_category(season = '17', category = 'boys')
      web_urls = DataAccess.get_high_school_div_stat_urls season, category
      web_urls.each do |url|
        compare_with_url url
      end
    end

    def compare_with_season(season = '17')
      %w|men women boys girls|.each { |category| compare_with_season_and_category season, category }
    end

    def compare_with_url(url)
      puts "Start validation of web url: #{url}"

      comparison = DataValidation::Comparison::ComparisonFactory.get_comparison(url)
      comparison.compare

      puts "Complete validation of web url: #{url}"
      puts '=============================='
    end
  end

end

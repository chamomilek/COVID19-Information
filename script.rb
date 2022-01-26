# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'
require 'terminal-table'
require 'active_support/all'
require_relative 'script'

class HTTP
  attr_reader :new_url, :filename

  def initialize(new_url, filename)
    @new_url = new_url
    @filename = filename
  end

  def access
    url = URI.parse(new_url)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    response = https.request(request)
    begin
      response.code == 200
    rescue StandardError
      puts 'Status code error!!'
    end
    status = JSON.parse(response.body)
    File.open(filename, 'w') do |f|
      f.write(JSON.pretty_generate(status))
    end
  end
end

class Json
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def parsing
    file = open(filename)
    json = file.read
    JSON.parse(json)['Countries']
  end

  def countries_list(parsed)
    parsed.map { |e| e['Country'] }
  end
end

class FileCache
  def self.open(lifetime: 24 * 60, format: :json)
    filename = 'country_info.json'
    begin
      data = if File.exist?(filename) && ((Time.now.to_i - File.mtime(filename).to_i) < lifetime * 60)
               puts content = File.read(filename)
               case format
               when :json
                 JSON.parse(content)
               end
             end
    rescue Exception
      # loading cache file failed
      data = nil
    end
    unless data
      data = yield
      File.open(filename, 'w') do |f|
        content = nil
        case format
        when :json
          content = data.to_json
        end
        f.print(content)
      end
    end
    data
  end
end

class Output
  attr_reader :argv, :status, :countries_result, :rows

  def initialize(argv, status, countries_result)
    @argv = argv
    @status = status
    @countries_result = countries_result
    @rows = []
  end

  def letter
    puts countries_result if argv == 'C'
  end

  def country_info
    FileCache.open(lifetime: 1) do
      (0...countries_result.size).each do |index|
        next unless argv == countries_result[index]
        # print status[index]
        rows << ['Country', status[index]['Country']]
        rows << ['CountryCode', status[index]['CountryCode']]
        rows << ['Slug', status[index]['Slug']]
        rows << ['NewConfirmed', status[index]['NewConfirmed']]
        rows << ['TotalConfirmed', status[index]['TotalConfirmed']]
        rows << ['NewDeaths', status[index]['NewDeaths']]
        rows << ['TotalDeaths', status[index]['TotalDeaths']]
        rows << ['NewRecovered', status[index]['NewRecovered']]
        rows << ['TotalRecovered', status[index]['TotalRecovered']]
        rows << ['Date', status[index]['Date']]
        table = Terminal::Table.new title: 'Covid-19 Information', rows: rows
        puts table
      end
    end
  end
end

filename = 'data.json'
puts 'Enter "C" to see the list of available countries'
puts 'Or enter country name to see Covid information'
htp = HTTP.new 'https://api.covid19api.com/summary', filename
htp.access
json = Json.new(filename)
status = json.parsing
countries_result = json.countries_list(status)
argv = gets.chomp
choice = Output.new(argv, status, countries_result)
choice.letter
choice.country_info
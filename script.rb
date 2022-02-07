# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'
require 'terminal-table'
require 'active_support/all'
require 'optparse'
require_relative 'script'

class HTTP
  attr_reader :new_url

  def initialize(new_url)
    @new_url = new_url
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
    JSON.parse(response.body)
  end
end

class OptParse
  def self.parse(country, structure_json, full_info)
    options = OpenStruct.new
    OptionParser.new do |parser|
      parser.on('-c', '--countries', 'List of countries') do
        puts country.list
      end
      parser.on('--s [VALUE]', String) do |s|
        options.s = s
        structure_json.open(full_info, s)
      end
    end.parse!
  end
end

class Country
  attr_reader :filename, :structure_json, :htp

  def initialize(filename, structure_json, htp)
    @filename = filename
    @structure_json = structure_json
    @htp = htp
  end

  def list
    if File.zero?(filename)
      structure_json.new_structure(htp)
    else
      f = File.open(filename, 'r')
      parsed = JSON.parse(f.read)
      parsed['cache'].keys
    end
  end
end

class Covid
  attr_reader :filename, :rows

  def initialize(filename)
    @rows = []
    @filename = filename
  end

  def statistics(argv)
    f = File.open(filename, 'r')
    parsed = JSON.parse(f.read)
    # argv = OptParse.parse(country, structure_json)
    parsed['cache'].select do |k,v| if (k == argv)
                                   rows << ['Country', v['Country']]
                                   rows << ['CountryCode', v['CountryCode']]
                                   rows << ['Slug', v['Slug']]
                                   rows << ['NewConfirmed', v['NewConfirmed']]
                                   rows << ['TotalConfirmed', v['TotalConfirmed']]
                                   rows << ['NewDeaths', v['NewDeaths']]
                                   rows << ['TotalDeaths', v['TotalDeaths']]
                                   rows << ['NewRecovered', v['NewRecovered']]
                                   rows << ['TotalRecovered', v['TotalRecovered']]
                                   rows << ['Date', v['Date']]
      table = Terminal::Table.new title: 'Covid-19 Information', rows: rows
      puts table
                                    end
    end
  end
end

class FileCache
  attr_reader :json, :full_info

  def initialize
    @str = {}
    @filename = 'data.json'
    @json = json
    @full_info = full_info
  end

  def new_structure(htp)
    json = htp.access
    data = json['Countries']
    hashtable = {}
    str = { updated_at: Time.now,
            cache: {} }

    data.each do |item|
      hashtable[item['Country']] = {
        'Country': item['Country'],
        'CountryCode': item['CountryCode'],
        'Slug': item['Slug'],
        'NewConfirmed': item['NewConfirmed'],
        'TotalConfirmed': item['TotalConfirmed'],
        'NewDeaths': item['NewDeaths'],
        'TotalDeaths': item['TotalDeaths'],
        'NewRecovered': item['NewRecovered'],
        'TotalRecovered': item['TotalRecovered'],
        'Date': item['Date']
      }
    end
    data.each do |item|
      str[:cache][item['Country']] = hashtable[item['Country']]
    end

    File.open(@filename, 'w') do |f|
      f.write(JSON.pretty_generate(str))
    end
  end

  def open(full_info, argv)
    $lifetime = 24 * 60
    if File.zero?(@filename)
      new_structure(json)
    else
      full_info.statistics(argv)
    end
  end
end

filename = 'data.json'
htp = HTTP.new 'https://api.covid19api.com/summary'
full_info = Covid.new(filename)
structure_json = FileCache.new
country = Country.new(filename, structure_json, htp)
OptParse.parse(country, structure_json, full_info)
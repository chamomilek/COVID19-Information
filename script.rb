# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'
require 'terminal-table'
require 'active_support/all'
require_relative 'script'
# Filename ||= '/data.json'

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
      status = JSON.parse(response.body)['Countries']
    File.open(filename, 'w') do |f|
      f.write(JSON.pretty_generate(status))
    end
  end
  # def countrs(status)
  #   countries = JSON.parse(status.map { |e| e['Country'] })
  #   end
  end

class FileCache
  def self.open(lifetime: 24 * 60, format: :json)
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
      File.open(filename, 'w') do |io|
        content = nil
        case format
        when :json
          content = data.to_json
        end
        io.print(content)
      end
    end
    data
  end
end

class Output
  attr_reader :argv, :status

  def initialize(argv, status)
    @argv = argv
    @status = status
  end

  def letter
    countrie if aRGV == 'C'
  end

  def country_info
    data = FileCache.open(lifetime: 1) do
      countrie = JSON.parse(status.map { |e| e['Country'] })
      (0...countrie.size).each do |index|
        next unless aRGV == countrie[index]
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
Filename = '/data.json'
puts 'Enter "C" to see the list of available countries'
puts 'Or enter country name to see Covid informarion'
htp = HTTP.new 'https://api.covid19api.com/summary', Filename
rows = []
aRGV = gets.chomp
status = htp.access
st = JSON.parse(Filename)
countrie = st.map { |e| e['Country'] }
# countrie = htp.countrs(status)
#
choice = Output.new(aRGV, status)
choice.country_info
choice.letter

# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'
require 'terminal-table'
require 'active_support/all'

class HTTP
  attr_reader :new_url

  def initialize(new_url)
    @new_url = new_url
  end

  def proxy
    url = URI.parse(new_url)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(url)
    response = https.request(request)
    status = JSON.parse(response.body)['Countries']
  end

  def cntrs(status)
    countries = status.map { |e| e['Country'] }
  end
end

module FileCache
  def self.open(lifetime: 24 * 60)
    begin
      filename = "C:\Users\Asus\Desktop\delete\кэш"
      data = if File.exist?(filename) && ((Time.now.to_i - File.mtime(filename).to_i) < lifetime * 60)
               puts content = File.read(filename)
             end
    rescue Exception
      # loading cache file failed
      data = nil
    end
    unless data
      data = yield
      File.open(filename, 'w') do |io|
        content = data
        io.print(content)
      end
    end
    data
  end
end

class Output
  include FileCache
  attr_reader :aRGV, :countrie, :rows, :status

  def initialize(aRGV, countrie, _rows, status)
    @aRGV = aRGV
    @countrie = countrie
    @rows = []
    @status = status
  end

  def letter
    data = FileCache.open(lifetime: 1) do
      countrie if aRGV == 'C'
    end
  end

  def c_name
    data = FileCache.open(lifetime: 1) do
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
      end
    end
  end
end

puts 'Enter "C" to see the list of available countries'
puts 'Or enter country name to see Covid informarion'
htp = HTTP.new 'https://api.covid19api.com/summary'
# file = File.new("C:\Users\Asus\Desktop\delete\кэш", 'w+', expires_in: 1.minute)
rows = []
aRGV = gets.chomp
status = htp.proxy
countrie = htp.cntrs(status)

choice = Output.new(aRGV, countrie, rows, status)
choice.letter
choice.c_name
# file_letter = File.open(file, 'r', &:read)
# cache = ActiveSupport::Cache::MemoryStore.new(expires_in: 1.minute)
# cache.fetch(file_letter) do
# choice.letter
# end
# cache.write(aRGV, choice.c_name(file))
# cache.read(file_letter)

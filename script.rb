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

class Cache
  def self.fetch key, expires_in = 30, &block
    @cache = {}
    if @cache.key?(key) && (@cache[key][:expiration_time] > Time.now.to_i)
      puts "fetch from cache and will expire in #{@cache[key][:expiration_time] - Time.now.to_i}"
      @cache[key][:value]
    else
      if block_given?
        puts "did not find key in cache, executing block"
        @cache[key] = {value: yield(block), expiration_time: Time.now.to_i + expires_in}
        @cache[key][:value]
      else
        nil
      end
    end
  end
end

class Output
  attr_reader :aRGV, :countrie, :rows, :status

  def initialize(aRGV, countrie, _rows, status)
    @aRGV = aRGV
    @countrie = countrie
    @rows = []
    @status = status
  end

  def letter
    puts countrie if aRGV == 'C'
  end

  def c_name
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

htp = HTTP.new 'https://api.covid19api.com/summary'
rows = []
aRGV = gets.chomp
status = htp.proxy
countrie = htp.cntrs(status)

puts 'Enter "C" to see the list of available countries'
puts 'Or enter country name to see Covid informarion'

choice = Output.new(aRGV, countrie, rows, status)
#  cache = ActiveSupport::Cache::MemoryStore.new(expires_in: 1.minute)
# cache.fetch(choice.c_name) do
#   choice.c_name
# end
#  cache.write(aRGV, choice.letter)
#  cache.fetch(choice.letter)

  Cache.fetch(choice.c_name) do
   choice.c_name
 end
Cache.fetch(choice.letter) do
  choice.letter
end

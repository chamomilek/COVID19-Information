# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'
require 'terminal-table'
require 'cachethod'
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

class Output
  include Cachethod
  cache_methods [:letter, :c_name], expires_in: 1.minutes

  attr_reader :aRGV, :countrie, :rows, :status

  def initialize(aRGV, countrie, rows, status)
    @aRGV = aRGV
    @countrie = countrie
    @rows = Array.new
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
# countrie = htp.proxy()
status = htp.proxy
countrie = htp.cntrs(status)

puts 'Enter "C" to see the list of available countries'
puts 'Or enter country name to see Covid informarion'
rows=[]
aRGV = gets.chomp
choice = Output.new(aRGV, countrie, rows, status)
choice.letter
choice.c_name

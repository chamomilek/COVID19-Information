# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'
require 'terminal-table'

url = URI.parse('https://api.covid19api.com/summary')

https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true

request = Net::HTTP::Get.new(url)
response = https.request(request)
status = JSON.parse(response.body)['Countries']
countries = status.map { |e| e['Country'] }
rows = []

puts 'Enter "C" to see the list of available countries'
puts 'Or enter country name to see Covid informarion'
ARGV[0] = gets.chomp

puts countries if ARGV[0] == 'C'
# if ARGV[0] == 'C'
#   table = Terminal::Table.new do |t|
#     t.headings = %w[id name]
#      (0...countries.size).each do |index|
#        t.rows[index] = [[index + 1], countries[index]]
#      end
#     t.style = { border_top: false, border_bottom: false }
#   end
#   puts table
# end

(0...countries.size).each do |index|
  next unless ARGV[0] == countries[index]

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

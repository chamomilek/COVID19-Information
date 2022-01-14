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

# class Cache
#   def self.fetch key, expires_in = 30, &block
#     @cache = {}
#     if @cache.key?(key) && (@cache[key][:expiration_time] > Time.now.to_i)
#       puts "fetch from cache and will expire in #{@cache[key][:expiration_time] - Time.now.to_i}"
#       @cache[key][:value]
#     else
#       if block_given?
#         puts "did not find key in cache, executing block"
#         @cache[key] = {value: yield(block), expiration_time: Time.now.to_i + expires_in}
#         @cache[key][:value]
#       else
#         nil
#       end
#     end
#   end
# end

class Output
  attr_reader :aRGV, :countrie, :rows, :status, :file

  def initialize(aRGV, countrie, _rows, status, _file)
    @aRGV = aRGV
    @countrie = countrie
    @rows = []
    @status = status
    @file = "C:\Users\Asus\Desktop\delete\кэш"
  end

  def letter(file)
    countrie if aRGV == 'C'
    file.puts('Name of countries: ')
    if File.zero?("C:\Users\Asus\Desktop\delete\кэш")
      file.puts(countrie)
      fh = open file
      fh.each do |line|
        puts line
      end
    end
    fh.close
  end

  def c_name(file)
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
      if File.zero?("C:\Users\Asus\Desktop\delete\кэш")
        file.puts(table)
        puts shw = file.read
      end
    end
  end
end

htp = HTTP.new 'https://api.covid19api.com/summary'
file = File.new("C:\Users\Asus\Desktop\delete\кэш", 'w+', expires_in: 1.minute)
rows = []
aRGV = gets.chomp
status = htp.proxy
countrie = htp.cntrs(status)

puts 'Enter "C" to see the list of available countries'
puts 'Or enter country name to see Covid informarion'

choice = Output.new(aRGV, countrie, rows, status, "C:\Users\Asus\Desktop\delete\кэш")
# choice.letter(file)
# choice.c_name(file)
file_letter = File.open(file, 'r', &:read)
cache = ActiveSupport::Cache::MemoryStore.new(expires_in: 1.minute)
cache.fetch(file_letter) do
  choice.letter(file)
end
cache.write(aRGV, choice.c_name(file))
cache.read(file_letter)

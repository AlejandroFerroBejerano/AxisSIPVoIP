require 'capybara'
require'capybara/dsl'
require 'open-uri'
require 'base64'
require 'fileutils'
require 'selenium-webdriver'
require 'csv'
include Capybara::DSL

# Inicializamos Capybara
Capybara.run_server = false
Capybara.default_driver = :selenium

input_array = ARGV



ENV['NO_PROXY']="127.0.0.1"
driver = Selenium::WebDriver.for :firefox


def get_file(data_file = "")
  until check_file(data_file) == false
    puts "\n Please introduce a valid source extensions file \".csv\" \n"
    data_file = gets.chomp
  end
  return data_file
end

def check_file(data_source)
  return_value = false
  puts "\n Checking file" + data_source + "\n"
  if File.file?(data_source) && File.extname(data_source) == ".csv"
    return_value = true
    puts "\nFile extension and location validated" + "\n"
  end
  return return_value
end

data_source = input_array[0]
extensions = []
account_url = "/admin//sip.shtml?"

puts "\n Introduzca usuario \n"
user = "root"
puts "\n Introduzca password \n"
pass = "Eds-bur09001"
# puts "\n Introduzca direccion puerto remoto del servidor sip. Ej 5061 \n"
# sipserver_port= gets.chomp
sipserver_port= "5060"

if ARGV.empty?
  until check_file(data_source)
    puts "Please introduce a valid source extensions file \".csv\" \n"
    data_source = gets.chomp
  end
else
  data_source = ARGV[0]
  check_file(data_source)
end

CSV.foreach(data_source, headers: true) do |row|
  extensions.push(row.to_hash)
end

extensions.each do |ext|
  user = ext['USER']
  pass = ext['PASS']

  ext_url = "http://" + user+"\:" + pass + "\@" + ext["IP"] + account_url
  visit ext_url
  # Esperamos a que cargue la web
 sleep(6)
  page.all("input[type='text']").each do |input_text|
  case input_text['id']
      when "portInput"
        input_text.set sipserver_port
      end
  end
  puts 'Selec the aviable codes and save'
  sleep(3)
  puts '4 Seconds To save'
  sleep(4)

end

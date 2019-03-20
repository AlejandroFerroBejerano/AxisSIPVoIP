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


ENV['NO_PROXY']="127.0.0.1"
#driver = Selenium::WebDriver.for :firefox


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

data_source = "alt_csv/alt_edsbur.csv"
extensions = []
device_maintenance = "/admin/maintenance.shtml?"

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


puts extensions.length

count = 0
while count < extensions.length do
  ext = extensions[count]
  user = ext['USER']
  pass = ext['PASS']
  ext_base_url = "http://" + user+"\:" + pass + "\@" + ext["IP"]
  puts ext_base_url + device_maintenance
  visit ext_base_url + device_maintenance
  # Esperamos a que cargue la web
  puts 'sleeping 3s'
  sleep(3)

  #Restart
  find("input[value='Restart']").click
  puts 'saving'
  puts 'Pleace accept Js Pop-Up Alert'
  page.driver.browser.switch_to.alert.accept
  sleep(4)
  count +=1
end

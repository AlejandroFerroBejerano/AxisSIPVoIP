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
audio_settings = "/operator/audio.shtml"

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

count = 2
while count < extensions.length do
  ext = extensions[count]
  user = ext['USER']
  pass = ext['PASS']
  ext_base_url = "http://" + user+"\:" + pass + "\@" + ext["IP"]
  puts ext_base_url + audio_settings
  visit ext_base_url + audio_settings
  # Esperamos a que cargue la web
  puts 'sleeping 3s'
  sleep(3)
  #Audio Channels
  #find('#root_Audio_DuplexMode').find(:xpath, 'option[3]').select_option
  find("option[value='full']").select_option
  sleep(1)
  #Encoding
  find("option[value='g711']").select_option
  sleep(1)
  #Bitrate
  #find("option[value='64000']").select_option
  #sleep(1)
  #Save
  find("input[value='Save']").click
  puts 'saving'
  count +=1
end

#extensions.each do |ext|
#  user = ext['USER']
#  pass = ext['PASS']
#  ext_base_url = "http://" + user+"\:" + pass + "\@" + ext["IP"]
#  puts ext_base_url + audio_settings
#  visit ext_base_url + audio_settings
#  # Esperamos a que cargue la web
#  puts 'sleeping 3s'
#  sleep(3)
#  #Audio Channels
#  #find('#root_Audio_DuplexMode').find(:xpath, 'option[3]').select_option
#  find("option[value='full']").select_option
#  sleep(1)
#  #Encoding
#  find("option[value='g711']").select_option
#  sleep(1)
#  #Bitrate
#  #find("option[value='64000']").select_option
#  #sleep(1)
#  #Save
#  find("input[id='audio_SaveBtn']").click
#  puts 'saving'
#end

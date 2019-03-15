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
# driver = Selenium::WebDriver.for :firefox


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

data_source = "int_pal.csv"
extensions = []
account_url = "/admin/account_set.shtml?doAction=add"

puts "\n Introduzca usuario \n"
user = "root"
puts "\n Introduzca password \n"
pass = "Ggp08970"
# puts "\n Introduzca direccion ip remota del servidor sip. Ej 10.147.254.209 \n"
# sipserver_ip = gets.chomp
sipserver_ip = "10.147.254.109"
# puts "\n Introduzca direccion puerto remoto del servidor sip. Ej 5061 \n"
# sipserver_port= gets.chomp
sipserver_port= "5160"

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
  ext_id = ext["IP"].split('.')[2] + ext["IP"].split('.').last
  ext_pass = ext_id
  user = ext['USER']
  pass = ext['PASS']
  puts ext_pass
  reg_addr = sipserver_ip + "\:"+ sipserver_port
  ext_name = ext["SITE CODE"] + "\-" + ext["IDENTIFICADOR"] + "\-" + ext["DESCRIPTOR"]
  ext_url = "http://" + user+"\:" + pass + "\@" + ext["IP"] + account_url
  visit ext_url
  # Esperamos a que cargue la web
 sleep(8)
  page.all("input[type='text']").each do |input_text|
    case input_text['name']
      when "name-input"
        input_text.set ext_name
      when "accountcallerid-input"
        input_text.set ext_id
      when "userpubdom-input"
        input_text.set sipserver_ip
      when "userreg-input"
        input_text.set reg_addr
      end
  end
  page.all("input[type='text'][name='userid-input']").first.set ext_id
  page.all("input[type='password']").first.set ext_pass
  sleep(1)
  page.all("input[name='action-save-btn']").first.click
  sleep(1)
end 

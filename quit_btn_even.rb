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
recipient_url = "/operator/recipient_setup.shtml?doAction=add"
event_url = "/operator/action_rule_setup.shtml?doAction=add"
action_rules_url = "/operator/action_rules.shtml?"

puts "\n Introduzca usuario \n"
user = "root"
puts "\n Introduzca password \n"
pass = "Eds-bur09001"
# puts "\n Introduzca un nombre para la cuenta del receptor (Recipient Name). Ej CCP_QUEUE \n"
# recipient_name = gets.chomp
recipient_name = "CCP_PUESTO_4"
# puts "\n Introduzca un número de extensión para la cola (Recipient Ext). Ej 254900 \n"
# recipient_queue_ext = gets.chomp
recipient_queue_ext = "2549004"
# puts "\n Introduzca direccion ip remota del servidor sip. Ej 10.147.254.209 \n"
# sipserver_ip = gets.chomp
sipserver_ip = "10.147.254."
# puts "\n Introduzca direccion puerto remoto del servidor sip. Ej 5061 \n"
# sipserver_port= gets.chomp
sipserver_port= "5060"

event_name = "BtnMakeCall"

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

ext = extensions[0]

extensions.each do |ext|
  ext_id = ext["IP"].split('.')[2] + ext["IP"].split('.').last
  ext_pass = ext_id
  user = ext['USER']
  pass = ext['PASS']
  puts ext_pass
  reg_addr = sipserver_ip + "\:"+ sipserver_port
  ext_name = ext["SITE CODE"] + "\-" + ext["IDENTIFICADOR"] + "\-" + ext["DESCRIPTOR"]
  ext_base_url = "http://" + user+"\:" + pass + "\@" + ext["IP"]
  ext_recipient_url = ext_base_url + recipient_url
  ext_event = ext_base_url + event_url
  visit ext_base_url + action_rules_url
  # Esperamos a que cargue la web
  sleep(6)
  #Type SIP
  rules = page.all("#idListContainer.selectList").all("tr")
  i_disbled_rules = []
  rules.each_with_index do |rule, index|
    event_name = rule.all("td")[1].text
    if event_name.include? "ButtonMakeCall-#{recipient_queue_ext}"
      i_disbled_rules.push(index)
    end
  end

  i_disbled_rules.each do |rule|
    puts rule
    sleep(3)
    page.all("#idListContainer.selectList").all("tr")[rule].all("td").first.click
    sleep(1)
  end
  sleep(6)
end

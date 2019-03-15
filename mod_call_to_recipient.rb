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

data_source = "test.csv"
extensions = []
account_url = "/admin/account_set.shtml?doAction=add"
recipient_url = "/operator/recipient_setup.shtml?doAction=add"
event_url = "/operator/action_rule_setup.shtml?doAction=add"
action_rules_url = "/operator/action_rules.shtml?"

puts "\n Introduzca usuario \n"
user = "root"
puts "\n Introduzca password \n"
pass = "Ggp08970"
# puts "\n Introduzca un nombre para la cuenta del receptor (Recipient Name). Ej CCP_QUEUE \n"
# recipient_name = gets.chomp
recipient_name = "CCP_PUESTO_1"
# puts "\n Introduzca un número de extensión para la cola (Recipient Ext). Ej 254900 \n"
# recipient_queue_ext = gets.chomp
recipient_queue_ext = "2549001"
# puts "\n Introduzca direccion ip remota del servidor sip. Ej 10.147.254.209 \n"
# sipserver_ip = gets.chomp
sipserver_ip = "10.147.254.109"
# puts "\n Introduzca direccion puerto remoto del servidor sip. Ej 5061 \n"
# sipserver_port= gets.chomp
sipserver_port= "5160"

event_name = "ButtonMakeCall"

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
  #Creamos el nuevo recipient
  visit ext_recipient_url
  # Esperamos a que cargue la web
  sleep(8)
  #Type SIP
  #page.all("select[id='recipientTemplates']").first.set "SIP"
  find("option[value='com.axis.recipient.sip']").select_option
  # works fine => find('#recipientTemplates').find(:xpath, 'option[7]').select_option
  sleep(1)
  page.all("input[type='text']").each do |input_text|
    case input_text['id']
      when "recipientName"
        #Name of the recipient
        input_text.set recipient_name
      end
  end
  #From SIP account
  # page.all("select[id='sip_clients_from']").first.set ext_name
  find("#sip_clients_from").all('option').last.select_option
  #To SIP address
  page.all("input[id='sip_url']").first.set recipient_queue_ext
  sleep(1)
  #Save
  page.all("input[id='btnOK']").first.click
  sleep(1)

  #Edit Event
  visit ext_base_url + action_rules_url
  sleep (8)
  # Action Rule - Name
  page.all("input[id='ruleName']").first.set event_name + "\-" +recipient_queue_ext
  # Action Rule - Condition
  find("option[value='group_3']").select_option
  sleep(1)
  find("option[value='0']").select_option
  ##Action
  find("option[value='sip_call']").select_option
  sleep(1)
  find("#recipientsip_call").find(:xpath, 'option[2]').select_option
  #Save
  page.all("input[id='btnOK']").first.click
  sleep(1)
end 

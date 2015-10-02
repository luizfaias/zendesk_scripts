require 'zendesk_api'
require 'commander/import'

program :version, '0.3'
program :description, 'This script allows you to delete all macros in your account'
program :help, 'Author', 'Luiz Faias <lfaias@zendesk.com>'
default_command :run

command :run do |c|
  c.description = 'just run :)'
  c.action do |args, options|

    say "\n"
    say "----------------------------------------------------------------"
    say "                    Delete ALL macros"
    say "----------------------------------------------------------------"
    say "\n"
    say "Please enter your account details below:                        "
    say "\n\n"

    url       = ask "Subdomain: (e.g mycompany.zendesk.com): "
    email     = ask "Email (e.g admin@company.com): "
    password  = ask ("Password: ") { |q| q.echo = "*" }
    say "\n"

    client = ZendeskAPI::Client.new do |config|
      config.url = "https://#{url}/api/v2"
      config.username = email
      config.password = password
      config.retry = true
    end

    count = 0

    client.macros.all do |macro|
      begin
        puts "Deleting macro ##{macro['id']}: ##{macro['title']}"
        macro.destroy
        count += 1
      rescue Exception => e
        puts e.response
      end
    end

    puts "\nDone! #{count} macro(s) deleted."
  end
end

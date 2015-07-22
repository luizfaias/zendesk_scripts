require 'zendesk_api'
require 'commander/import'

program :version, '0.1'
program :description, 'This script allows you to delete organizations'
program :help, 'Author', 'Luiz Faias <lfaias@zendesk.com>'
default_command :run

command :run do |c|
  c.description = 'just run :)'
  c.action do |args, options|

    say "\n"
    say "----------------------------------------------------------------"
    say "                Delete Zendesk Organizations"
    say "----------------------------------------------------------------"
    say "\n"
    say "Please enter your account details below:                        "
    say "\n\n"

    url       = ask "URL (e.g https://{subdomain}.zendesk.com/api/v2): "
    email     = ask "Email (e.g admin@company.com): "
    api_token = ask ("API Token: ") { |q| q.echo = "*" }

    client = ZendeskAPI::Client.new do |config|
      config.url = url
      config.username = email
      config.token = api_token
      config.retry = true
    end

    organizations = client.connection.get("organizations.json?per_page=200").body
    organizations["organizations"].each do |organization|
      begin
        if organization['tags'].include? "venue"
          puts "\nDeleting organization with name = " + organization['name']
          client.connection.delete("organizations/#{organization['id']}.json")
        end
      rescue Exception => e
        puts e
      end
    end
  end
end

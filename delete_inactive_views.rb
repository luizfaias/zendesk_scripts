require 'zendesk_api'
require 'commander/import'

program :version, '0.2'
program :description, 'This script allows you to delete all inactive shared (not personal) views'
program :help, 'Author', 'Luiz Faias <lfaias@zendesk.com>'
default_command :run

command :run do |c|
  c.description = 'just run :)'
  c.action do |args, options|

    say "\n"
    say "----------------------------------------------------------------"
    say "             Delete all inactive shared views"
    say "----------------------------------------------------------------"
    say "\n"
    say "Please enter your account details below:                        "
    say "\n\n"

    url       = ask "URL (e.g https://{subdomain}.zendesk.com/api/v2): "
    email     = ask "Email (e.g admin@company.com): "
    api_token = ask ("API Token: ") { |q| q.echo = "*" }
    say "\n"

    client = ZendeskAPI::Client.new do |config|
      config.url = url
      config.username = email
      config.token = api_token
      config.retry = true
    end

    count = 0

    client.views.all do |view|
      begin
        unless view.restriction
          unless view.active
            puts "Deleting view ##{view['id']}: ##{view['title']}"
            client.connection.delete("views/#{view['id']}.json")
            count += 1
          end
        end
      rescue Exception => e
        puts e.response
      end
    end

    puts "\nDone! #{count} view(s) deleted."
  end
end

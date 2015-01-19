require 'zendesk_api'
require 'commander/import'

program :version, '0.1'
program :description, 'This script allows you to make all comments private (for every single ticket)'
program :help, 'Author', 'Luiz Faias <lfaias@zendesk.com>'
default_command :run

command :run do |c|
  c.description = 'just run :)'
  c.action do |args, options|

    say "\n"
    say "----------------------------------------------------------------"
    say "                 Make all comments private"
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

    client.tickets.all do |ticket|
      ticket.comments.all do |comment|
        begin
          if comment.public
            puts "\nUpdating comment ##{comment['id']} for ticket ##{ticket['id']}"
            client.connection.put("tickets/#{ticket['id']}/comments/#{comment['id']}/make_private.json")
          else
            puts "\nComment ##{comment['id']} for ticket ##{ticket['id']} was already private"
          end
        rescue Exception => e
          puts e.response
        end
      end
    end
  end
end

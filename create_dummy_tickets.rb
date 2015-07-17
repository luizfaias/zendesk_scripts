require 'zendesk_api'
require 'net/http'
require 'commander/import'

program :version, '0.4'
program :description, 'This script allows you to create dummy tickets inside your Zendesk test account'
program :help, 'Author', 'Luiz Faias <lfaias@zendesk.com>'
default_command :run

command :run do |c|
  c.description = 'just run :)'
  c.action do |args, options|

    say "\n"
    say "----------------------------------------------------------------"
    say "               Create Dummy Tickets for Zendesk"
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

    say "----------------------------------------------------------------"
    say "              Creating 100 dummy tickets..."
    say "----------------------------------------------------------------"

    for i in 1..100
      resp = Net::HTTP.get_response(URI.parse('http://loripsum.net/api/1/plaintext/headers/short'))
      subject = resp.body.match(/^(.*)$/)[0].to_s

      resp = Net::HTTP.get_response(URI.parse('http://jaspervdj.be/lorem-markdownum/markdown-html.html?num-blocks=3'))
      description = resp.body.match(/<pre class="markdown">((.|\n)*)<\/pre>/)[1].to_s

      ticket_form_id = 31391

      tags = ["random_tag_1", "random_tag_2", "random_tag_3", "random_tag_4"]
      random_tag = tags.sample

      requesters = [633258692, 648518222, 659373142, 660385471, 707750852]
      random_requester = requesters.sample

      ticket = client.tickets.create(:subject => subject, :comment => { :value => description }, :ticket_form_id => ticket_form_id, :requester_id => random_requester, :tags => random_tag)
      p ticket.url
    end
  end
end

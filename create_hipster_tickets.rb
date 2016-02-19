require 'zendesk_api'
require 'rest-client'
require 'commander/import'

program :version, '0'
program :description, 'This script allows you to create dummy tickets inside your Zendesk test account with Hipster content'
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
    url       = ask "Subdomain: (e.g mycompany.zendesk.com): "
    email     = ask "Email (e.g admin@company.com): "
    api_token = ask ("API Token (will not be displayed): ") { |q| q.echo = "*" }

    client = ZendeskAPI::Client.new do |config|
      config.url = "https://#{url}/api/v2"
      config.username = email
      config.token = api_token
      config.retry = true
    end

    say "----------------------------------------------------------------"
    say "              Creating 100 dummy tickets..."
    say "----------------------------------------------------------------"

    tickets = []
    response = RestClient.get 'http://hipsterjesus.com/api', {:params => {:paras => 99, :type => 'hipster-centric', :html => false}}
    content = JSON.parse(response)["text"]
    lines = content.split('.')

    for i in 1..100
      subject = lines[i].strip!
      description = lines[i*2].strip!

      tags = ["random_tag_1", "random_tag_2", "random_tag_3", "random_tag_4"]
      random_tag = tags.sample

      requesters = [4763584258, 4769837337, 3548192408, 4105094477]
      random_requester = requesters.sample

      ticket = {:subject => subject, :comment => { :value => description }, :requester_id => random_requester, :tags => random_tag}
      tickets.push ticket
    end

    job_status = client.tickets.create_many!(tickets)
    say "Done. Check the job status."
    say job_status.url
  end
end

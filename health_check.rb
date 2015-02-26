#!/usr/bin/env ruby
require 'net/http'
require 'net/smtp'

MAILING_LIST = ['nikoletos@hotmail.com']

def ping_api_1
  get_check('http://www.technikally.com/')
end
def ping_api_2
  get_check('http://example.com/resources')
end

def get_check(url) 
  begin
    res = Net::HTTP.get_response(URI(url))
    if res.code == "200"
      puts "alive #{url}"
    else
      send_message("Something wrong with #{url} and #{res.code}")
    end
  rescue => e
    send_message("Something wrong with #{url} #{e.inspect}")
  end
end


def full_message(msg)
<<MESSAGE_END
From: Bot Monitor <bot_email@gmail.com>
To: Developers
MIME-Version: 1.0
Content-type: text/html
Subject: #{msg}

<h2>Error</h2>
<br/>
#{msg}<br/>
<br/>

MESSAGE_END
end

def send_message(msg)
  smtp = Net::SMTP.new('smtp.gmail.com', 587)
  smtp.enable_starttls
  smtp.start("gmail.com", ENV['USERNAME'], ENV['PASSWORD'], :login) do |smtp|
    smtp.send_message(full_message(msg), ENV['USERNAME'], MAILING_LIST)
  end
end

puts "Start scanning at #{Time.now}"

threads = []
threads << Thread.new { ping_api_1 }
threads << Thread.new { ping_api_2 }

threads.each do |t|
  t.join
end
puts "Complete scanning at #{Time.now}"

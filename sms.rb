#!/usr/bin/env ruby

require 'digest/md5'
require 'optparse'
require 'faraday'


unless ARGV.size > 0
  $stderr.puts "No options specified"
  exit(false)
end


options = {}

ARGV.options do |opts|
  opts.on('-u', '--username USERNAME', String) { |value| options[:username] = value }
  opts.on('-p', '--password PASSWORD', String) { |value| options[:password] = value }
  opts.on('-r', '--recipient RECIPIENT', String) { |value| options[:recipient] = value }
  opts.on('-m', '--message MESSAGE', String) { |value| options[:message] = value }
  opts.parse!
end

class SMS
  def initialize(options)
    @options = options
    @api = 'http://api.smsbrana.cz/smsconnect/http.php'

    @time = Time.now.strftime("%Y%m%dT%H%M%S")
    @salt = genhash

    @apiargs = {
      login: @options[:username],
      sul: @salt,
      time: @time,
      hash: Digest::MD5.hexdigest(@options[:password] + @time + @salt)
    }
  end

  def genhash
    return (0...8).map { (65 + rand(26)).chr }.join
  end

  def send
    @apiargs.update(action: 'send_sms', number: @options[:recipient], message: @options[:message])

    conn = Faraday.new
    response = conn.get @api, @apiargs
    puts response.body
  end
end


sms = SMS.new(options)
sms.send


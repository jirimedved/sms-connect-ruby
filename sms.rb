#!/usr/bin/env ruby

require 'digest/md5'
require 'optparse'
require 'faraday'
require 'yaml'


unless ARGV.size > 0
  $stderr.puts "No options specified"
  exit(false)
end


options = {}

ARGV.options do |opts|
  opts.on('-r', '--recipient RECIPIENT', String) { |value| options[:recipient] = value }
  opts.on('-m', '--message MESSAGE', String) { |value| options[:message] = value }
  opts.parse!
end

class SMS
  def initialize(options)
    @options = options
    @credentials = YAML.load_file('/etc/sms-connect/sms.yml')[:sms]
    @api = 'http://api.smsbrana.cz/smsconnect/http.php'

    @time = Time.now.strftime("%Y%m%dT%H%M%S")
    @salt = genhash

    @apiargs = {
      login: @credentials[:username],
      sul: @salt,
      time: @time,
      hash: Digest::MD5.hexdigest(@credentials[:password] + @time + @salt)
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
    exit
  end
end


sms = SMS.new(options)
sms.send

#! usr/bin/env ruby

#Chat App. Using comments regularly for the first time. Tryin to get into the habit. #This file is the server. To join it, run Towel.rb
#!/usr/bin/env ruby -w
require "socket"
class TelnetTowel
  def initialize(port, ip)
    @server = TCPServer.open(ip, port)
    @connections = Hash.new
    @rooms = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:clients] = @clients
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do |client|
        nickName = client.gets.chomp.to_sym
        @connections[:clients].each do |otherName, otherClient|
          if nickName == otherName or client == otherClient
            client.puts "This Username is already being used."
            Thread.kill self
          end
        end
        puts "#{nickName} #{client}"
        @connections[:clients][nickName] = client
        client.puts ""
        listenUserMessages(nickName, client)
      end
    }.join
  end

  def listenUserMessages(username, client)
    loop {
      msg = client.gets.chomp
      @connections[:clients].each do |otherName, otherClient|
        unless otherName == username
          otherClient.puts "#{username.to_s}: #{msg}"
        end
      end
    }
  end
end

TelnetTowel.new(3000, "localhost")

require "sinatra/base"
require "puma"
require "json"

class Server < Sinatra::Base

  configure do
    set :bind, "0.0.0.0"
  end

  get "/" do
    ip_info = `curl https://ipinfo.io/`
    begin
      ip_info = JSON.parse(ip_info)
    rescue
      ip_info = {}
    end
    openvpn_grep = `ps aux | grep openvpn | grep -v grep`
    connected = openvpn_grep.lines.length > 0 ? "connected" : "not_connected"
    @vpn = {
      :status => connected,
      :ip => ip_info["ip"],
      :country => ip_info["country"],
      :city => ip_info["city"],
      :state => ip_info["region"],
      :org => ip_info["org"]
    }
    erb :index
  end

end

Server.run!
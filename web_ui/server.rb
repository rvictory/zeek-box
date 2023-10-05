require "sinatra/base"
require "puma"
require "json"
require_relative 'lib/eink_updater'
require_relative 'lib/utils'

class Server < Sinatra::Base

  ZEEK_LOG_DIR = "/opt/zeek_logs/"
  @@mutex = Mutex.new
  @@last_refreshed = Time.now.to_i

  configure do
    set :bind, "0.0.0.0"
  end

  get "/" do
    @title = "Home"
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
    @@mutex.synchronize do
      if Time.now.to_i - @@last_refreshed > 15
        EInkUpdater.trigger_refresh
        @@last_refreshed = Time.now.to_i
      end
    end

    data = `tail -100 #{File.join(ZEEK_LOG_DIR, "dns.log")}`
    @zeek_domain_names = data.lines.map {|x| JSON.parse(x)}

    erb :index
  end

  get "/kill_vpn" do
    `pkill openvpn`
    redirect "/"
  end

  get "/rotate_vpn" do
    `ruby /opt/utils/rotate_vpn.rb us`
    sleep 10
    redirect "/"
  end

  get "/enable_mitmproxy" do
    `/bin/enable_mitmproxy.sh`
    redirect "/"
  end

  get "/disable_mitmproxy" do
    `/bin/disable_mitmproxy.sh`
    redirect "/"
  end

  get "/recent_zeek_dns_queries" do
    data = `tail -100 #{File.join(ZEEK_LOG_DIR, "dns.log")}`
    parsed = data.lines.map {|x| JSON.parse(x)["query"]}.uniq

  end

end

Server.run!
class Utils

  def self.is_mitmproxy_active?
    begin
      iptables_info = `iptables-save`
    rescue
      iptables_info = ""
    end
    !/mitmproxy/.match(iptables_info).nil?
  end

  def self.is_killswitch_active?
    File.exist?("/opt/killswitch")
  end

end
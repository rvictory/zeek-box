# Manages zeek logs
require_relative "./zeek_logs/zeek_dns_log"

class ZeekManager

  def initialize(log_dir)
    @log_dir = log_dir
    @dns_logs = nil
  end

  def dns_logs
    @dns_logs = ZeekDNSLog.new(File.join(@log_dir, "dns.log")) unless @dns_logs
    @dns_logs
  end

end
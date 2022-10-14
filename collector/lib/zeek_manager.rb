# Manages zeek logs
require_relative "./zeek_logs/ek_dns_log"
require_relative "./zeek_logs/zeek_conn_log"

class ZeekManager

  def initialize(log_dir)
    @log_dir = log_dir
    @dns_logs = nil
    @conn_logs = nil
  end

  def dns_logs
    @dns_logs = ZeekDNSLog.new(File.join(@log_dir, "dns.log")) unless @dns_logs
    @dns_logs
  end

  def conn_logs
    @conn_logs = ZeekConnLog.new(File.join(@log_dir, "conn.log")) unless @conn_logs
    @conn_logs
  end

end
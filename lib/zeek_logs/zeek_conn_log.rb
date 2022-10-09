# Manages the Zeek Conn log
require "json"
require_relative "./zeek_log_base"

class ZeekConnLog < ZeekLogBase

  def initialize(log_path, format = "json")
    raise ArgumentError.new "Can only handle JSON logs for now" unless format == "json"
    @log_path = log_path
    raise ArgumentError.new "Log Path Doesn't Exist" unless File.exist?(log_path)
    @entries = IO.read(log_path).lines.map {|x| ZeekConnLogEntry.new(JSON.parse(x))}
  end

  def unique_destination_ips_for_host(orig_h, start_ts=0, finish_ts=0)
    logs_within_timestamps(start_ts, finish_ts)
      .select {|x| x.orig_h == orig_h}.map {|x| x.resp_h + ":" + x.resp_p.to_s}.uniq
  end

  def unique_source_hosts(start_ts=0, finish_ts=0)
    logs_within_timestamps(start_ts, finish_ts).map {|x| x.orig_h}.uniq
  end

end

class ZeekConnLogEntry

  attr_reader :ts, :uid, :orig_h, :orig_p, :resp_h, :resp_p, :proto, :duration, :orig_bytes, :resp_bytes, :conn_state, :missed_bytes, :history, :orig_pkts, :orig_ip_bytes, :resp_pkts, :resp_ip_bytes

  def initialize(data)
    @ts = data['ts']
    @uid = data['uid']
    @orig_h = data['id.orig_h']
    @orig_p = data['id.orig_p']
    @resp_h = data['id.resp_h']
    @resp_p = data['id.resp_p']
    @proto = data['proto']
    @duration = data['duration']
    @orig_bytes = data['orig_bytes']
    @resp_bytes = data['resp_bytes']
    @conn_state = data['conn_state']
    @missed_bytes = data['missed_bytes']
    @history = data['history']
    @orig_pkts = data['orig_pkts']
    @orig_ip_bytes = data['orig_ip_bytes']
    @resp_pkts = data['resp_pkts']
    @resp_ip_bytes = data['resp_ip_bytes']
  end

end
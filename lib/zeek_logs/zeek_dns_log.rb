# Manages the Zeek DNS log
require "json"
require_relative "./zeek_log_base"

class ZeekDNSLog < ZeekLogBase

  def initialize(log_path, format = "json")
    raise ArgumentError.new "Can only handle JSON logs for now" unless format == "json"
    @log_path = log_path
    raise ArgumentError.new "Log Path Doesn't Exist" unless File.exist?(log_path)
    @entries = IO.read(log_path).lines.map {|x| ZeekDNSLogEntry.new(JSON.parse(x))}
  end

  def unique_queries_for_host(orig_h, start_ts=0, finish_ts=0)
    logs_within_timestamps(start_ts, finish_ts)
      .select {|x| x.orig_h == orig_h}.map {|x| x.query}.uniq
  end

  def unique_query_hosts(start_ts=0, finish_ts=0)
    logs_within_timestamps(start_ts, finish_ts).map {|x| x.orig_h}.uniq
  end

end

class ZeekDNSLogEntry

  attr_reader :ts, :uid, :orig_h, :orig_p, :resp_h, :resp_p, :proto, :trans_id, :rtt, :query, :qclass, :qclass_name, :qtype, :qtype_name, :rcode, :rcode_name, :aa, :tc, :rd, :ra, :z, :answers, :ttls, :rejected

  def initialize(data)
    @ts = data['ts']
    @uid = data['uid']
    @orig_h = data['id.orig_h']
    @orig_p = data['id.orig_p']
    @resp_h = data['id.resp_h']
    @resp_p = data['id.resp_p']
    @proto = data['proto']
    @trans_id = data['trans_id']
    @rtt = data['rtt']
    @query = data['query']
    @qclass = data['qclass']
    @qclass_name = data['qclass_name']
    @qtype = data['qtype']
    @qtype_name = data['qtype_name']
    @rcode = data['rcode']
    @rcode_name = data['rcode_name']
    @aa = data['AA']
    @tc = data['TC']
    @rd = data['RD']
    @ra = data['RA']
    @z = data['Z']
    @answers = data['answers']
    @ttls = data['TTLs']
    @rejected = data['rejected']
  end

end
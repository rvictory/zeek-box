# Collects the results of running Zeek for a specified time period
require_relative 'lib/zeek_manager'
require_relative 'lib/ses_emailer'

if ARGV.empty?
  puts "How to use:"
  puts "ruby collector.rb path/to/log/dir/ comma,separated,source,ips start_ts-end_ts"
  exit
end

# Parse the command line
puts ARGV.inspect
zeek_log_dir = ARGV[0]
create_zip = true
start_ts = 0
finish_ts = 0
if ARGV.length > 1
  start_ts, finish_ts = ARGV[1].split("-").map {|x| x.to_i}
end
ignore_dest_ips = []

if ARGV.length > 2
  source_ips = ARGV[2].split(",")
else
  source_ips = []
end
timestamps = []

# Grab and parse the log files
# We need to handle two situations: a log dir with logs from a full run or a log dir of rotated logs
zeek_manager = ZeekManager.new(zeek_log_dir)

# Create the high level summary

# Create the domain name list
domain_names = {}
ips = source_ips.empty? ? zeek_manager.dns_logs.unique_query_hosts(start_ts, finish_ts) : source_ips
ips.each do |ip|
  domain_names[ip] = zeek_manager.dns_logs.unique_queries_for_host(ip, start_ts, finish_ts)
end

# Create the communicated IP list
dest_ips = {}
ips = source_ips.empty? ? zeek_manager.conn_logs.unique_source_hosts(start_ts, finish_ts) : source_ips
ips.each do |ip|
  dest_ips[ip] = zeek_manager.conn_logs.unique_destination_ips_for_host(ip, start_ts, finish_ts)
end

# Create the HTTP list

# Create the log Zip file

# Put together the HTML and attach log zip
str = ""
str += "<br />" +  "------------------------------------"
str += "<br />" +  "Destination IP Report"
str += "<br />" +  "------------------------------------"
dest_ips.each do |ip, entries|
  str += "<br />" +  "Source IP: #{ip}"
  str += "<br />" +  entries.map {|x| "\t#{x}"}.join("<br />")
  str += "<br />"
end
str += "<br />"
str += "<br />" +  "------------------------------------"
str += "<br />" +  "Domain Name Report"
str += "<br />" +  "------------------------------------"

domain_names.each do |ip, entries|
  str += <<END
<h3>Source IP: #{ip}</h3>
<table>
<thead>
<tr>
<th>Domain Name</th>
</tr>
</thead>
<tbody>
#{entries.map {|x| "<tr><td>#{x}</td></tr>"}.join("\n")}
</tbody>
</table>
END
  str += "<br />"
end
str += "<br />"

# Send the email
emailer = SESEmailer.new
emailer.send_email("Zeek Report at #{Time.now.to_s}", str, 'zeek_reports@raptormail.net', "Zeek Reports", [ENV["REPORT_EMAIL"]], [""])
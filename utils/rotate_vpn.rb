# This script rotates the vpn connection by selecting a random configuration file from /opt/openvpn/

country_code = ""
if ARGV.length > 0
  country_code = ARGV.first.downcase
  puts "Using country code #{country_code}"
end

puts "Killing any existing OpenVPN instance"
`pkill openvpn`
#sleep 1

if ENV.has_key?("USE_STARVPN")
  puts "Using StarVPN"
  Dir.chdir("/opt/openvpn")
  `openvpn --config /opt/openvpn/starvpn.ovpn --daemon`
else
  puts "Picking a random configuration file and re-running OpenVPN"
  files = Dir.glob("/opt/openvpn/#{country_code}*.ovpn")
  file = files.shuffle.first
  Dir.chdir("/opt/openvpn")
  puts "Using #{file}"
  `openvpn --config #{file} --daemon`
end

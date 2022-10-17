# Run this from a directory to add all of the NordVPN configuration files to that directory

html = `curl https://nordvpn.com/ovpn/`

file_list = []

html.lines.each do |line|
  if line =~ /"https:\/\/downloads.nordcdn.com\/configs\/files\/ovpn_legacy\/servers\/(.*?.nordvpn.com.udp.*?.ovpn)"/
    file_list.push("https://downloads.nordcdn.com/configs/files/ovpn_legacy/servers/" + $1)
  end
end

file_list.each do |file|
  file_name = file.split("/").last
  data = `curl #{file}`
  data.gsub!("auth-user-pass", "auth-user-pass /etc/openvpn/auth.txt")
  File.open(file_name, "w") {|x| x.puts data}
end
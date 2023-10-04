# Monitors for tun0, if tun0 disappears, turn off wlan0

KILLSWITCH_PATH = "/opt/killswitch"
sleep_duration = 0.5

while true do
  sleep sleep_duration
  begin
    ifconfig = `ifconfig tun0 2>&1`
  rescue
    next
  end
  if ifconfig =~ /Device not found/
    puts "Killswitch activated!"
    File.open(KILLSWITCH_PATH, "w") {|x| x.puts Time.now.to_i.to_s} unless File.exist?(KILLSWITCH_PATH)
    `ifconfig wlan0 down`
    sleep_duration = 3
  else
    sleep_duration = 0.5
    # Clear the killswitch
    File.delete(KILLSWITCH_PATH) if File.exist?(KILLSWITCH_PATH)
    `ifconfig wlan0 up`
  end
end
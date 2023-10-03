class EInkUpdater
  def self.trigger_refresh
    eink_pid_path = "/opt/waveshare/pid"
    return unless File.exist?(eink_pid_path)
    pid = IO.read(eink_pid_path).to_i
    Process.kill('USR1', pid)
  end
end
class ZeekLogBase
  attr_reader :entries

  def initialize
    @entries = []
  end

  def logs_within_timestamps(start_ts, finish_ts)
    if finish_ts == 0
      entries
    else
      entries.select {|x| x.ts >= start_ts && x.ts <= finish_ts}
    end
  end
end
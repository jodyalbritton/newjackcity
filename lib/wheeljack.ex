defmodule Wheeljack do



alias GrovePi.Analog
alias GrovePi.RGBLCD, as: Screen

  def start_link do
    Agent.start_link(fn -> %{detected: false} end)
  end

  def put(pid, key, value) do
    Agent.update(pid, &Map.put(&1, key, value))
  end

  def get(pid, key) do
    Agent.get(pid, &Map.get(&1, key))
  end

  def stop(pid) do
    Agent.stop(pid)
  end


  def detect_light(start_time, pid) do


    current_time = :os.system_time(:milli_seconds)

    if current_time - start_time < 10000 do
      detected = Wheeljack.get(pid, :detected)

      if detected == false do
        read = Analog.read(14)
        if read > 500 do
          time_2 = :os.system_time(:milli_seconds)

          diff = time_2 - start_time

          Screen.set_text("PASS "<> Integer.to_string(diff))
          Screen.set_rgb(0,0,255)
          Wheeljack.put(pid, :detected, true)
        else
          detect_light(start_time, pid)
        end
      else
        Screen.set_text("FAIL")
        Screen.set_rgb(255,0,0)
      end
    end


  end


  def config_arm(num, time) do
    Analog.write(3, num)
    :timer.sleep(time)
    Analog.write(3, 0)
  end

  def open_arm() do
     Analog.write(3, 245)
     :timer.sleep(500)
     Analog.write(3, 0)
  end

  def close_arm() do
     Analog.write(3, -245)
     :timer.sleep(800)
     Analog.write(3, 0)
  end


  def run_test(iterations) do

     for n <- 1..iterations do
       {:ok, pid} = Wheeljack.start_link
       open_arm()
       time_1 = :os.system_time(:milli_seconds)
       detect_light(time_1, pid)

       :timer.sleep(10000)

       close_arm()
       Wheeljack.stop(pid)
     end
  end

end

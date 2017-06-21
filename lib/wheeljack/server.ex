defmodule Wheeljack.Server do

  use GenServer


  def start_link() do
     GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    unless :os.type == {:unix, :darwin} do     # don't start networking unless we're on nerves
      {:ok, pid} = Nerves.Networking.setup(:eth0)
    end
    {:ok, state}
  end

end

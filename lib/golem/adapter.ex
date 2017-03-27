defmodule Golem.Adapter do
  @callback send(message :: String.t) :: {:ok, result :: term} | {:error, reason :: String.t}
  @callback connect :: {:ok, result :: PID.t} | {:error, reason :: String.t}
end
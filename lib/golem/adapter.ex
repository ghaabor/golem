defmodule Golem.Adapter do
  @moduledoc """
  Golem chat adapter behaviour.
  """

  @callback send(message :: String.t) ::
    {:ok, result :: term} | {:error, reason :: String.t}

  @callback connect ::
    {:ok, result :: PID.t} | {:error, reason :: String.t}
end

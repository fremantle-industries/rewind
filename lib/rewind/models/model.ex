defmodule Rewind.Models.Model do
  @enforce_keys ~w[id input receiver quotes trades candles indicators]a
  defstruct ~w[id input receiver quotes trades candles indicators]a

  defimpl Stored.Item do
    def key(m) do
      m.id
    end
  end
end

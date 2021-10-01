defmodule Rewind.Models do
  alias __MODULE__

  def load(config \\ Application.get_env(:rewind, :models, %{})) do
    models = config
             |> Enum.map(fn {id, {factory, input_config}} ->
               {:ok, model} = apply(factory, :build, [id, input_config])
               {:ok, _} = Models.ModelStore.put(model)
               model
             end)

    {:ok, models}
  end

  def search(_query) do
    Models.ModelStore.all()
  end

  def find(id) when is_bitstring(id), do: id |> String.to_atom() |> find()
  def find(id), do: Models.ModelStore.find(id)
end

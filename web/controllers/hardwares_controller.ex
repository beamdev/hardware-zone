defmodule HardwareZone.HardwaresController do
  use Phoenix.Controller
  alias HardwareZone.Hardware
  alias HardwareZone.Repo
  alias HardwareZone.Router

  def index(conn, _params) do
    hardwares = HardwareZone.Queries.all_hardwares
    render conn, "index", hardwares: hardwares
  end

  def new(conn, _params) do
    render conn, "new", hardware: %Hardware{}
  end

  def create(conn, %{"hardware" => params}) do
    hardware = Map.merge(%Hardware{}, atomize_keys(params))
    case Hardware.validate(hardware) do
      [] ->
        hardware = Repo.insert(hardware)
        redirect conn, Router.hardwares_path(:show, hardware.id)
      errors ->
        render conn, "new", hardware: hardware, errors: errors
    end
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Hardware, String.to_integer(id)) do
      hardware when is_map(hardware) ->
        render conn, "show", hardware: hardware
      _ -> 
        redirect conn, Router.hardwares_path(:index)
    end
  end

  def edit(conn, %{"id" => id}) do
    case Repo.get(Hardware, String.to_integer(id)) do
      hardware when is_map(hardware) ->
        render conn, "edit", hardware: hardware
      _ ->
        redirect conn, Router.hardwares_path(:index)
    end
  end

  def update(conn, %{"id" => id, "hardware" => params}) do
    case Repo.get(Hardware, String.to_integer(id)) do
      hardware when is_map(hardware) ->
        hardware = Map.merge(hardware, atomize_keys(params))
        case Hardware.validate(hardware) do
          [] -> 
            Repo.update(hardware)
            redirect conn, Router.hardwares_path(:show, hardware.id)
          errors -> 
            IO.puts (inspect errors)
            render conn, "edit", hardware: hardware, errors: errors
        end
      _ ->
        redirect conn, Router.hardwares_path
    end
  end

  def destroy(conn, %{"id" => id}) do
    case Repo.get(Hardware, String.to_integer(id)) do
      hardware when is_map(hardware) ->
        Repo.delete(hardware)
        redirect conn, Router.hardwares_path(:index)
      _ ->
        redirect conn, Router.hardwares_path(:index)
    end
  end
  
  defp atomize_keys(struct) do
    Enum.reduce struct, %{}, fn({k, v}, map) -> Map.put(map, String.to_atom(k), v) end
  end
end

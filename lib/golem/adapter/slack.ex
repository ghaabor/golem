defmodule Golem.Adapter.Slack do
  @behaviour Golem.Adapter

  alias Golem.Adapter.Slack

  require Logger

  use Tesla, docs: false
  plug Tesla.Middleware.BaseUrl, "https://slack.com/api"
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Query, [token: Application.fetch_env!(:golem, :slack_token)]

  def connect do
    ws_uri = 
      case rtm_start() do
        {:ok, ws_url} -> URI.parse(ws_url)
        {:error, reason} ->
          error_msg = "[#{reason[:status]}] #{reason[:body]}"
          error_msg |> Logger.error
          {:error, error_msg}
      end

    socket = Socket.Web.connect! ws_uri.host, secure: true, path: ws_uri.path
    {resp_type, resp} = socket |> Socket.Web.recv! 
    mesg = resp |> parse_response
    case mesg[:type] do
      "hello" ->
        "Slack RTM connection successful" |> Logger.info
        case start_slack_supervisor(socket) do
          {:ok, pid} -> {:ok, pid}
          {:error, reason} -> {:error, reason}
        end        
      "error" ->
        mesg[:error][:msg] |> Logger.error
        {:error, mesg[:error][:msg]}
      _ ->
        error_msg = "Unexpected opening message from Slack RTM"
        error_msg |> Logger.error
        {:error, error_msg}
    end
  end

  defp rtm_start do
    response = get("/rtm.start")
    if response.status == 200 do
      :ets.new(:config, [:named_table, :public])
      :ets.new(:users, [:named_table])
      for user <- response.body["users"] do
        :ets.insert(:users, {user["id"], user})
      end
      {:ok, response.body["url"]}
    else
      {:error, [status: response.status, body: response.body]}
    end
  end

  defp parse_response(resp) do
    Poison.Parser.parse!(resp, keys: :atoms!)
  end

  defp start_slack_supervisor(socket) do
    import Supervisor.Spec

    children = [
      worker(Task, [Slack.Socket, :recv!, [socket]])
    ]
    opts = [strategy: :one_for_one, name: Slack.Supervisor]

    Supervisor.start_link(children, opts)
  end

end
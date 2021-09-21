defmodule FlyWeb.AppLive.Show do
  use FlyWeb, :live_view
  require Logger

  alias Fly.Client
  alias FlyWeb.Components.HeaderBreadcrumbs

  @default_interval 30

  @impl true
  def mount(%{"name" => name}, session, socket) do
    socket =
      assign(socket,
        config: client_config(session),
        state: :loading,
        app: nil,
        app_name: name,
        app_status: nil,
        authenticated: true,
        update_count: 0
      )

    # Only make the API call if the websocket is setup. Not on initial render.
    if connected?(socket) do
      app_status = fetch_app_status(socket, true)
      app = fetch_app(socket)

      update_timer(@default_interval)

      {:ok, assign(socket, app: app, app_status: app_status)}
    else

      {:ok, socket}
    end
  end

  # Handles live page data refresh
  @impl true
  def handle_info(:update_info, socket) do
    update_timer(@default_interval)

    app_status = fetch_app_status(socket, true)
    app = fetch_app(socket)
    {
      :noreply,
      assign(
        socket,
        app: app,
        app_status: app_status,
        update_count: socket.assigns.update_count + 1
      )
    }
  end

  defp fetch_app(socket) do
    app_name = socket.assigns.app_name

    case Client.fetch_app(app_name, socket.assigns.config) do
      {:ok, app} ->
        app

      {:error, :unauthorized} ->
        put_flash(socket, :error, "Not authenticated")

      {:error, reason} ->
        Logger.error("Failed to load app '#{inspect(app_name)}'. Reason: #{inspect(reason)}")

       put_flash(socket, :error, reason)
    end
  end

  # fetch app status
  defp fetch_app_status(socket, show_completed) do
    name = socket.assigns.app_name

   case Client.fetch_app_status(name, show_completed, socket.assigns.config) do
      {:ok, app_status} ->
        app_status

      {:error, :unauthorized} ->
        put_flash(socket, :error, "Not authenticated")

      {:error, reason} ->
        Logger.error("Failed to load app status of '#{inspect(name)}'. Reason: #{inspect(reason)}")

        put_flash(socket, :error, reason)
    end
  end

  # Function that sets the interval for updating live page data
  defp update_timer(interval) do
    Process.send_after(self(), :update_info, interval * 1000)
  end

  defp client_config(session) do
    Fly.Client.config(access_token: session["auth_token"] || System.get_env("FLYIO_ACCESS_TOKEN"))
  end

  def status_bg_color(app) do
    case app["status"] do
      "running" -> "bg-green-100"
      "dead" -> "bg-red-100"
      _ -> "bg-yellow-100"
    end
  end

  def status_text_color(app) do
    case app["status"] do
      "running" -> "text-green-800"
      "dead" -> "text-red-800"
      _ -> "text-yellow-800"
    end
  end

  def preview_url(app) do
    "https://#{app["name"]}.fly.dev"
  end

  # make the Regions friendly for the user to read without
  # turning to the Fly documentation for help.
  # It'll be cool to fetch and process this from Fly API to keep it updated.
  def regions_friendly(symbol) when is_binary(symbol) do
    case symbol do
      "ams" ->  "Amsterdam, Netherlands"
      "atl" -> 	"Atlanta, Georgia (US)"
      "cdg" -> 	"Paris, France"
      "dfw" ->	"Dallas, Texas (US)"
      "ewr" ->	"Parsippany, NJ (US)"
      "fra" ->	"Frankfurt, Germany"
      "gru" ->	"Sao Paulo, Brazil"
      "hkg" ->	"Hong Kong"
      "iad" ->	"Ashburn, Virginia (US)"
      "lax" ->	"Los Angeles, California (US)"
      "lhr" ->	"London, United Kingdom"
      "nrt" ->	"Tokyo, Japan"
      "ord" ->	"Chicago, Illinois (US)"
      "scl" ->	"Santiago, Chile"
      "sea" ->	"Seattle, Washington (US)"
      "sin" ->	"Singapore"
      "sjc" ->	"Sunnyvale, California (US)"
      "syd" ->	"Sydney, Australia"
      "vin" ->	"Vint Hill, Virginia"
      "yyz" ->	"Toronto, Canada"
      _ ->      "#[{symbol}]"
    end
  end

    # make the date/time friendly to read
    # example: converts: "2021-09-13T10:27:34Z" to: "Sept 13, 2021. 10:27:am"
    def datetime_friendly(datetime_string)
    when is_binary(datetime_string) do
      {:ok, datetime} =
        datetime_string
          |> string_to_datetime()
          |> Timex.format("{YYYY}, {Mshort} {0D}. {h12}:{m} {am}")
      datetime
    end

  # Duration from last update eg: 3 days ago
  def updated_duration(datetime_string)
  when is_binary(datetime_string) do
      datetime_string
        |> string_to_datetime()
        |> Timex.from_now()
  end
  # datetime_string = "2021-09-13T10:27:34Z"
  defp string_to_datetime(datetime_string)
  when is_binary(datetime_string) do
    {:ok, datetime_u} =
      Timex.parse(datetime_string, "{RFC3339}")

    datetime_u
  end

  ### listing the nested <checks> items in:
  # %{"allocations" => [%{"checks" => [ %{ "name" => "", ...}, ...], ...}, ...], ...}
  # requires this form of nested loop in the temlate:
  # for appstat <- app_status["allocations"] do
  #   for checks_map <- Map.get(appstat, "checks") do
  #     checks_map["name"]
  #   end
  # end
end

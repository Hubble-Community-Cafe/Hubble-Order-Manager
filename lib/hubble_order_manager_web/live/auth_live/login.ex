defmodule HubbleOrderManagerWeb.AuthLive.Login do
  use HubbleOrderManagerWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-sm space-y-4">
      <.form
          :let={f}
          for={@form}
          id="login_form_token"
          action={~p"/login"}
          phx-submit="submit_token"
          phx-trigger-action={@trigger_submit}
        >
          <.input
            field={f[:token]}
            type="password"
            label="Token"
            autocomplete="current-password"
          />
          <.button class="w-full" variant="primary">
            Log in <span aria-hidden="true">→</span>
          </.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    form = to_form(%{"token" => nil}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  def handle_event("submit_token", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end
end

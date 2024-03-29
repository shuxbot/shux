defmodule Shux.Bot.Commands.Avatar do
  @behaviour Shux.Bot.Command

  alias Shux.Bot.Components
  alias Shux.Discord.Api

  def help() do
    %{
      usage: "sx!avatar @user",
      description: "Muestra el avatar del usuario.",
      perms: :user,
      options: ""
    }
  end

  def run(_perms, msg, _args) do
    user = if Enum.empty?(msg.mentions), do: msg.author, else: hd(msg.mentions)
    is_gif = String.starts_with?(user.avatar, "a_")

    avatar_ext = if is_gif, do: ".gif", else: ".png"

    content =
      "https://cdn.discordapp.com/avatars/#{user.id}/#{user.avatar <> avatar_ext}?size=1024"

    Api.send_message(msg.channel_id, %{
      content: content,
      components: [
        Components.action_row([
          Components.avatar_btn(user.id),
          Components.url_btn(content)
        ])
      ]
    })

    {:ok, nil}
  end
end

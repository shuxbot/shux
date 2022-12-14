defmodule Shux.Discord.Api do
  use HTTPoison.Base

  @endpoint "https://discord.com/api/v10"

  def headers do
    [
      {"Authorization", "Bot " <> Application.get_env(:shux, :bot_token)},
      {"Content-Type", "application/json"}
    ]
  end

  def process_url(url) do
    @endpoint <> url
  end

  def send_message(ch_id, content) when is_binary(content) do
    post(
      "/channels/#{ch_id}/messages",
      Poison.encode!(%{content: content}),
      headers()
    )
  end

  def send_message(ch_id, message) when is_map(message) do
    post(
      "/channels/#{ch_id}/messages",
      Poison.encode!(message),
      headers()
    )
  end

  def send_image(ch_id, image) do
    body =
      {:multipart,
       [
         {"file", image, {"form-data", [name: "file", filename: "profile.png"]}, []}
       ]}

    post(
      "/channels/#{ch_id}/messages",
      body,
      [
        {"Authorization", "Bot " <> Application.get_env(:shux, :bot_token)},
        {"Content-Type", "multipart/form-data"}
      ]
    )
  end

  def user_avatar(user = %{avatar: "a_" <> avatar}), do: user_avatar(%{user | avatar: avatar})

  def user_avatar(user) do
    %HTTPoison.Response{body: body} =
      HTTPoison.get!("https://cdn.discordapp.com/avatars/#{user.id}/#{user.avatar}.png")

    body
  end

  def create_channel(guild_id, channel) when is_map(channel) do
    post(
      "/guilds/#{guild_id}/channels",
      Poison.encode!(channel),
      headers()
    )
  end

  def delete_channel(channel_id) when is_binary(channel_id),
    do: delete("/channels/#{channel_id}", headers())

  def interaction_callback(interaction, response) when is_map(response) do
    post(
      "/interactions/#{interaction.id}/#{interaction.token}/callback",
      Poison.encode!(response),
      headers()
    )
  end
end

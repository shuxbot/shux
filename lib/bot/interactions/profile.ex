defmodule Shux.Bot.Interactions.Profile do
  alias Shux.Bot.Leveling.LevelXpConverter
  alias Shux.ImageBuilder
  alias Shux.Api
  alias Shux.Discord
  alias Shux.Bot.Components

  def run(interaction) do
    has_resolved = Map.get(interaction.data, :resolved) != nil

    user =
      if has_resolved do
        key = hd(Map.keys(interaction.data.resolved.users))

        Map.get(interaction.data.resolved.users, key)
      else
        interaction.member.user
      end

    target_id =
      if Map.get(interaction.data, :target_id) != nil do
        interaction.data.target_id
      else
        user.id
      end

    %{points: points, warnings: warns, description: desc} = Api.get_user!(target_id)

    username = user.username
    level = LevelXpConverter.xp_to_level(points)
    avatar = Discord.Api.user_avatar(user)

    image =
      ImageBuilder.Profile.build(
        avatar,
        {
          username,
          "#{points}",
          "#{level}",
          "#{warns}",
          desc
        }
      )

    disabled = target_id != interaction.member.user.id

    response = %{
      type: 4,
      data: %{
        content: "",
        components: [
          Components.action_row([
            Components.profile_avatar_btn(user.id),
            Components.banner_btn(user.id),
            Components.description_btn(user.id, disabled)
          ])
        ]
      }
    }

    Discord.Api.interaction_callback(interaction, response, image)
  end
end
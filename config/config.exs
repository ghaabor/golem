use Mix.Config

config :logger, level: :debug

config :golem, slack_token: System.get_env("SLACK_TOKEN")
config :golem, adapter: Golem.Adapter.Slack

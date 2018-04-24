# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# By default, the umbrella project as well as each child
# application will require this configuration file, ensuring
# they all use the same configuration. While one could
# configure all applications here, we prefer to delegate
# back to each application for organization purposes.
import_config "../apps/*/config/config.exs"

# Sample configuration (overrides the imported configuration above):
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]

config :nostrum,
  token: "Mzk1OTY1NDA3OTEzMDUwMTIy.DSajEw.q8pCB9h-xgc12hwhoZMN3Rk97nM",
  num_shards: :auto

config :logger,
  level: :debug

config :discord,
  com_prefix: "!",
  bot_id: 395965407913050122

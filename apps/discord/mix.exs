defmodule Discord.Mixfile do
  use Mix.Project

  def project do
    [
      app: :discord,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Discord.Application, []},
      extra_applications: [:logger, :nostrum]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, git: "https://github.com/Kraigie/nostrum.git"},
      {:gun, git: "https://github.com/ninenines/gun.git", ref: "dd1bfe4d6f9fb277781d922aa8bbb5648b3e6756", override: true},
    ]
  end
end

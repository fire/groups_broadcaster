defmodule GroupsBroadcaster.MixProject do
  use Mix.Project

  def project do
    [
      app: :groups_broadcaster,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Broadcaster, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:khepri, "0.4.1"},
      {:jason, "~> 1.3"}
    ]
  end
end

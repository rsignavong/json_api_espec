defmodule JsonApiEspec.MixProject do
  use Mix.Project

  def project do
    [
      app: :json_api_espec,
      version: "0.1.0",
      elixir: "~> 1.8",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:espec, "~> 1.7"},
      {:ex_doc, "~> 0.19.3"}
    ]
  end

  def package do
    [
      description: "Json Api ESpec custom matcher to write quick and nice tests",
      licenses: ["MIT"],
      maintainers: ["Rocky Signavong"],
      links: %{
        "GitHub" => "https://github.com/rsignavong/json_api_espec"
      },
      files: ~w(mix.exs README.md lib)
    ]
  end
end

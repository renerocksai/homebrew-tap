# Generated from verified published v0.2.5 assets by scripts/homebrew_formula.py.
# Regenerate for the next release; do not edit checksum entries by hand.
require "json"
require "shellwords"

class Omagma < Formula
  desc "Account-separated Gmail terminal client and agent CLI"
  homepage "https://technologylab-ai.github.io/omagma/"
  version "0.2.5"
  license "MIT"

  on_macos do
    depends_on macos: :ventura
    on_arm do
      url "https://github.com/technologylab-ai/omagma/releases/download/v0.2.5/omagma-0.2.5-macos-arm64.tar.gz"
      sha256 "294f72c8ff3df71f4745cd60c3d4142bd08e3ab8e02a1e9bf80f8904f9278ed7"
    end
    on_intel do
      url "https://github.com/technologylab-ai/omagma/releases/download/v0.2.5/omagma-0.2.5-macos-x86_64.tar.gz"
      sha256 "27c9197ce855cde9edde13649599aeb37c09644ef3eac2996d553b516d06f6e7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/technologylab-ai/omagma/releases/download/v0.2.5/omagma-0.2.5-linux-arm64.tar.gz"
      sha256 "a9d11454ca41b4f8a66b880ecdfa7d47aa6fc925dca626b3a3408e0499193b58"
    end
    on_intel do
      url "https://github.com/technologylab-ai/omagma/releases/download/v0.2.5/omagma-0.2.5-linux-x86_64.tar.gz"
      sha256 "614dc43946571f6be27f2da35a1ca1db91fa7621ce5e6c62e696e2655f991a17"
    end
  end

  def install
    bin.install "zig-out/bin/omagma"
    doc.install "README.md", "AGENTS.md", "docs", "skills"
    pkgshare.install "examples", "LICENSE", "LICENSES"
    cp_r pkgshare/"examples", doc
  end

  def caveats
    <<~TEXT
      Start the terminal client with: omagma tui
      Account setup: https://technologylab-ai.github.io/omagma/docs/setup/
      Agent setup: https://technologylab-ai.github.io/omagma/docs/agent-setup/
      Installed skill: #{opt_prefix}/share/doc/omagma/skills/omagma-setup/SKILL.md
      Fictional example: #{opt_prefix}/share/omagma/examples/config.json

      Keep your own account configuration and OAuth downloads outside the keg.
      Connecting Gmail needs Google Chrome, system CA certificates and your
      explicit Google consent. macOS uses the native Keychain; Linux needs
      secret-tool and a running Secret Service. The Omarchy bar uses the Linux
      plugin bundle. Installation creates no accounts and grants no mail access.
    TEXT
  end

  test do
    %w[CONFIG CACHE DATA STATE].each do |kind|
      ENV["XDG_#{kind}_HOME"] = (testpath/kind.downcase).to_s
    end
    ENV["XDG_RUNTIME_DIR"] = (testpath/"runtime").to_s
    (testpath/"runtime").mkpath
    (testpath/"runtime").chmod 0700
    %w[DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE DBUS_SESSION_BUS_ADDRESS].each { |key| ENV.delete(key) }
    config = testpath/"fictional-config.json"
    config.write JSON.generate(accounts: [{address: "personal@example.com", profile: "Profile 1", enabled: true, required: true}])
    config.chmod 0600
    common = ["--fixtures", "--config", config.to_s, "--cache-dir", (testpath/"mail-cache").to_s,
              "--cache-messages", "3",
              "--account", "personal@example.com"]
    list = JSON.parse(shell_output(Shellwords.join([bin/"omagma", "mail", "refresh", *common,
                                                   "--limit", "3", "--prefetch-bodies", "3"])))
    assert_equal true, list.fetch("ok")
    assert_equal "personal@example.com", list.fetch("account")
    assert_equal %w[demo-96 demo-95 demo-94], list.fetch("data").fetch("messages").map { |mail| mail.fetch("id") }
    body = JSON.parse(shell_output(Shellwords.join([bin/"omagma", "mail", "read", *common,
                                                   "--message-id", "demo-96", "--cached"])))
    assert_equal true, body.fetch("ok")
    assert_match "Hello from personal@example.com!", body.fetch("data").fetch("bodyText")
    stats = JSON.parse(shell_output(Shellwords.join([bin/"omagma", "cache", "stats", *common, "--cached"])))
    assert_equal true, stats.fetch("ok")
    assert_equal 0, stats.fetch("data").fetch("fixtureSends")
    assert_equal 3, stats.fetch("data").fetch("metadataEntries")
  end
end

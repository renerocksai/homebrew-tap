# Generated from verified published v0.2.4 assets by scripts/homebrew_formula.py.
# Regenerate for the next release; do not edit checksum entries by hand.
require "json"
require "shellwords"

class Omagma < Formula
  desc "Account-separated Gmail terminal client and agent CLI"
  homepage "https://technologylab-ai.github.io/omagma/"
  version "0.2.4"
  license "MIT"

  on_macos do
    depends_on macos: :ventura
    on_arm do
      url "https://github.com/technologylab-ai/omagma/releases/download/v0.2.4/omagma-0.2.4-macos-arm64.tar.gz"
      sha256 "43ec9419908556ba1a0b52889645705939eef5789a27753c255ebe3c10acfbef"
    end
    on_intel do
      url "https://github.com/technologylab-ai/omagma/releases/download/v0.2.4/omagma-0.2.4-macos-x86_64.tar.gz"
      sha256 "2285e4c7638e76cf2e1c19c934c4b1fa6e23e25f6d2ca818a9d1d9375465f82b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/technologylab-ai/omagma/releases/download/v0.2.4/omagma-0.2.4-linux-arm64.tar.gz"
      sha256 "6535cc2cad0e1c8a9561ced8369178182142e20310a65c73f5ccec11459df604"
    end
    on_intel do
      url "https://github.com/technologylab-ai/omagma/releases/download/v0.2.4/omagma-0.2.4-linux-x86_64.tar.gz"
      sha256 "e4cdf4aaa9338d79f676b17142b76a40bbdcab11c4733a589e4a589ac029643b"
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

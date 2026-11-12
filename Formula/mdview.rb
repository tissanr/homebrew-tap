class Mdview < Formula
  desc "Minimal, fast-starting native Markdown viewer for macOS with live reload"
  homepage "https://github.com/tissanr/MumMD"
  url "https://github.com/tissanr/MumMD/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "83de80ee0436c8da74f7485e67c6d10593e5caad4a4ac37fc74a5a3d094bbe91"
  license "GPL-3.0-only"

  depends_on macos: :monterey

  resource "marked" do
    url "https://cdn.jsdelivr.net/npm/marked@15.0.12/marked.min.js"
    sha256 "3e7e7d7feb3e5d58cb6c804f68ab5c24cc7e5eb6270fd6e5cbb9124739217d0c"
  end

  def install
    (buildpath/"vendor").install resource("marked")
    ENV["MARKED_JS"] = (buildpath/"vendor/marked.min.js").to_s
    ENV["NO_INSTALL"] = "1"
    system "./build.sh"
    prefix.install "build/MDView.app"

    # `mdview datei.md` im Terminal öffnet die Datei in MDView.
    (bin/"mdview").write <<~SH
      #!/bin/sh
      exec /usr/bin/open -a "#{opt_prefix}/MDView.app" "$@"
    SH
  end

  def caveats
    <<~EOS
      MDView.app was installed to:
        #{opt_prefix}/MDView.app

      To use it from Finder, Spotlight and "Open With", link it into Applications:
        ln -sf "#{opt_prefix}/MDView.app" ~/Applications/MDView.app

      Open files from the terminal with:
        mdview README.md
    EOS
  end

  test do
    app = prefix/"MDView.app/Contents"
    assert_predicate app/"MacOS/MDView", :executable?
    assert_path_exists app/"Resources/marked.min.js"
    assert_path_exists app/"Resources/AppIcon.icns"
  end
end

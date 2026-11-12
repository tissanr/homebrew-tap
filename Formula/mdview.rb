class Mdview < Formula
  desc "Minimal, fast-starting native Markdown viewer for macOS with live reload"
  homepage "https://github.com/tissanr/MumMD"
  url "https://github.com/tissanr/MumMD/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "0ad222245bf755273574ef8a52acdb8376155ccfbc9ea1d5f7e0d996a370896e"
  license "GPL-3.0-only"
  revision 1

  depends_on macos: :monterey

  resource "marked" do
    url "https://cdn.jsdelivr.net/npm/marked@15.0.12/marked.min.js"
    sha256 "3e7e7d7feb3e5d58cb6c804f68ab5c24cc7e5eb6270fd6e5cbb9124739217d0c"
  end

  resource "highlight.js" do
    url "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.11.1/build/highlight.min.js"
    sha256 "c4a399dd6f488bc97a3546e3476747b3e714c99c57b9473154c6fb8d259b9381"
  end

  def install
    (buildpath/"vendor").install resource("marked")
    (buildpath/"vendor").install resource("highlight.js")
    ENV["MARKED_JS"] = (buildpath/"vendor/marked.min.js").to_s
    ENV["HLJS_JS"] = (buildpath/"vendor/highlight.min.js").to_s
    ENV["NO_INSTALL"] = "1"
    system "./build.sh"
    prefix.install "build/MDView.app"

    # `mdview datei.md` im Terminal öffnet die Datei in MDView.
    # Beim ersten Aufruf wird die App nach ~/Applications verlinkt (Finder, Spotlight,
    # „Öffnen mit“). Das geht nicht während `brew install`, weil Homebrew dort in einer
    # Sandbox läuft, die keine Schreibzugriffe ins Home-Verzeichnis erlaubt.
    (bin/"mdview").write <<~SH
      #!/bin/sh
      app="#{opt_prefix}/MDView.app"
      link="$HOME/Applications/MDView.app"
      if [ ! -e "$link" ]; then
        mkdir -p "$HOME/Applications" && ln -sfn "$app" "$link" &&
          /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$link" >/dev/null 2>&1
      fi
      exec /usr/bin/open -a "$app" "$@"
    SH
  end

  def caveats
    <<~EOS
      MDView.app was installed to:
        #{opt_prefix}/MDView.app

      Open files from the terminal with:
        mdview README.md

      The first run of `mdview` links MDView.app into ~/Applications, so it
      shows up in Finder, Spotlight and "Open With". To do that right away:
        mdview
    EOS
  end

  test do
    app = prefix/"MDView.app/Contents"
    assert_predicate app/"MacOS/MDView", :executable?
    assert_path_exists app/"Resources/marked.min.js"
    assert_path_exists app/"Resources/highlight.min.js"
    assert_path_exists app/"Resources/AppIcon.icns"
  end
end

cask "flclashhx" do
  version "VERSION"

  on_macos do
    arch arm: "arm64", intel: "amd64"

    sha256 arm:   "ARM_SHA256",
           intel: "AMD_SHA256"

    url "https://github.com/ABOLUOmathh/FlClashHX/releases/download/v#{version}/FlClashHX-#{version}-macos-#{arch}.dmg"
  end

  name "FlClashHX"
  desc "Multi-platform proxy client based on ClashMeta"
  homepage "https://github.com/ABOLUOmathh/FlClashHX"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "FlClashHX.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-rd", "com.apple.quarantine", "{{appdir}}/FlClashHX.app"],
        writable_paths: ["FlClashHX.app"],
        writable_base:  :appdir
  end

  uninstall quit: "com.follow.clashhx"

  zap trash: [
    "~/Library/Application Support/com.follow.clashhx",
    "~/Library/Caches/com.follow.clashhx",
    "~/Library/Preferences/com.follow.clashhx.plist",
    "~/Library/Saved Application State/com.follow.clashhx.savedState",
  ]
end

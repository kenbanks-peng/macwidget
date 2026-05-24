# MacWidget

No-Xcode macOS desktop CPU history widget-style app.

This is **not WidgetKit** because native macOS desktop widgets require an embedded app extension, signing, App Groups, and the Xcode workflow. This app instead creates a borderless desktop-level panel that behaves like a lightweight desktop widget and updates live.

## Run

```sh
swift run macwidget
```

## Build

```sh
swift build -c release
.build/release/macwidget
```

## Deploy as a LaunchAgent

```sh
mise run deploy
```

This builds the release binary, installs it to `~/.local/bin/macwidget`, installs `~/Library/LaunchAgents/com.kenbanks.macwidget.plist`, and starts it.

Useful tasks:

```sh
mise run restart
mise run undeploy
```

## Behavior

- Samples CPU usage once per second.
- Draws an Activity Monitor-style green history graph.
- Uses a borderless, draggable desktop panel.
- Runs as an accessory app, so it does not show a Dock icon.
- Requires no Apple Developer account and no Xcode project.


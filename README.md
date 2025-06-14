# xbuild.vim

**xbuild.vim** is a lightweight Vim plugin that helps iOS developers build, test, and run their Xcode projects directly from within Vim using `xcodebuild`.

## 🚀 Features

Run common development tasks without leaving Vim:

| Command | Description |
|---------------------------|---------------------------------------------------------------------------------|
| `:XScheme` | Select a build scheme (`-scheme`). |
| `:XDestination` | Choose a destination (`-destination`) for building, testing, or running. |
| `:XBuild` | Builds the current project using the selected scheme and destination. |
| `:XTest` | Runs tests using the selected scheme and destination. |
| `:XTestWithoutBuilding` | Runs tests without building (assumes the target is already built). |
| `:XRun` | Builds and runs the app on the selected destination. **Important**: works with simulator only.|
| `:XRunWithoutBuilding` | Launches the app on the selected destinations (assumes it's already installed). **Important**: works with simulator only.|
| `:XInfo` | Shows current settings such as scheme, destination and etc. |

## ⚙️ Requirements

- macOS with Xcode and `xcodebuild`
- _Optional_ [`xcpretty`](https://github.com/supermarin/xcpretty) for clean output

## 📦 Installation

Using vim's plugins:

```
git clone git@github.com:RVetas/xbuild.vim.git ~/.vim/pack/plugins/start/xbuild.vim
```

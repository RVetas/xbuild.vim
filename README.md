# xbuild.vim

**xbuild.vim** is a lightweight Vim plugin that helps iOS developers build, test, and run their Xcode projects directly from within Vim using `xcodebuild`.

## 🚀 Features

Run common development tasks without leaving Vim:

| Command                   | Description                                                                     |
|---------------------------|---------------------------------------------------------------------------------|
| `:XWorkspace`             | Automatically finds and sets the `.xcworkspace` for the current project.        |
| `:XScheme`                | Select a build scheme (`-scheme`).                                              |
| `:XDestination`           | Choose a destination (`-destination`) for building, testing, or running.        |
| `:XBuild`                 | Builds the current project using the selected scheme and destination.           |
| `:XTest`                  | Runs tests using the selected scheme and destination.                           |
| `:XTestWithoutBuilding`   | Runs tests without building (assumes the target is already built).              |
| `:XBuildAndRun`           | Builds and runs the app on the selected destination.                            |
| `:XRun`                   | Launches the app on the selected destinations (assumes it's already installed). |

## ⚙️  Requirements
- macOS with Xcode and `xcodebuild`
- [`xcpretty`](https://github.com/supermarin/xcpretty) for clean output

## 📦 Installation

Using vim's plugins:
```
# https:
git clone git@github.com:RVetas/xbuild.vim.git ~/.vim/pack/plugins/start/xbuild.vim
# ssh:
git clone git@github.com:RVetas/xbuild.vim.git ~/.vim/pack/plugins/start/xbuild.vim
```

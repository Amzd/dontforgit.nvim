# dontforgit.nvim

Don't forget to commit and push your changes anymore!

If you are like me and often quit NeoVim without committing or pushing, this plugin will remind you to do so.

## Installation


```lua
{
  "amzd/dontforgit.nvim",
  config = function()
    require("dontforgit").setup()
  end
}
```
Options

```lua
require("dontforgit").setup {
    -- If you often work in projects without git then turn this off to stop this plugin pestering you
    notify_git_failed = true,
    -- If you want to use a different git command (eg for dotfiles when in home directory) you can do so here
    git_command = "git",
    -- If you always do `:!git <something>` then you can set this to "!git " to save typing
    -- or if you want to use fugitive you might want to set this to ""
    prompt_prefix = "!",
    -- Wether to add `-s` to `git status` command
    compact = false,
    -- Disable the hint
    disable_hint = false
}
```

## Usage

Quit NeoVim without committing or pushing and you will be prompted to do so.

When you have committed and pushed everything it automatically quits.

You can use <Esc>/<C-c>, or :q to close without committing everything.

You can <Enter> without any input (either empty string or same as config.prompt_prefix) to run git status again.

NeoNoName.lua
===

Layout preserving buffer deletion in Lua.

## DEMO

https://user-images.githubusercontent.com/24765272/174682735-6112d411-c2bc-4fdb-86ba-b41e67ea198b.mov


## TL;DR

This plugin manages the only `[No Name]` buffer as a replacement to achieve layout-preserving buffer-deletion.


## Intro.

The main function of this plugin is `lua require('neo-no-name').neo_no_name(cmd_bn, cmd_bp)`,
where both params are optional(default to `bn`, `bp`, resp.)

Two facts:
- call `lua require('neo-no-name').neo_no_name(cmd_bn, cmd_bp)` at any buffer that is not `[No Name]`...
  - will remove duplicate `[No Name]` buffers if there are many. (This clean-up your buffer list)
  - will swap your current buffer with the `[No Name]` buffer. (will create one if it doesn't exist)
- call `lua require('neo-no-name').neo_no_name(cmd_bn, cmd_bp)` again at the `[No Name]` buffer...
  - will delete the buffer that just got swapped out.
  - and jump to the next buffer of that deleted buffer
    - by providing both `cmd_bn`, `cmd_bp`, you can define "the next/prev buffer" with your own logic

### APIs

Sometimes you don't want to call `cmd_bn`/`cmd_bp` on certain types of buffers.
In this case, you can use `before_hooks` with `abort()`:

```lua
before_hooks = {
  -- this abort `NeoNoName` when calling on terminal buffer created by ibhagwan/fzf-lua.
  function (u)
    if vim.bo.filetype == 'fzf' then
      vim.api.nvim_input('a<Esc>')
      u.abort()
    end
  end,
}
```

More APIs will be provided when needed. Feel free to create an issue/PR telling about what you need.


## Example Config

This is an example for [wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
-- remove `use` if you're using folke/lazy.nvim
use {
  'nyngwang/NeoNoName.lua',
  config = function ()
    require('neo-no-name').setup {
      before_hooks = {
        function (u)
          if vim.bo.filetype == 'fzf' then
            vim.api.nvim_input('a<Esc>')
            u.abort()
          end
        end,
      }
    }
    -- replace the current buffer with the `[No Name]`.
    vim.keymap.set('n', '<M-w>', function () vim.cmd('NeoNoName') end)
    -- the plain old buffer delete.
    vim.keymap.set('n', '<Leader>bd', function ()
      vim.cmd('NeoNoName')
      vim.cmd('NeoNoName')
    end)
  end
}
```

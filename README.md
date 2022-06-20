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
- call `lua require('neo-no-name').neo_no_name(cmd_bn, cmd_bp)` at non-`[No Name]` buffer
  - will change the current buffer to the only one `[No Name]` buffer
  - if the only one `[No Name]` buffer does not exist, it will be created
- call `lua require('neo-no-name').neo_no_name(cmd_bn, cmd_bp)` at `[No Name]` buffer
  - will delete the previous buffer
  - and jump to the next buffer of the just-deleted buffer(by providing both `cmd_bn`, `cmd_bp`, you can define your own "the next buffer")


## Install


```lua
use {
  'nyngwang/NeoNoName.lua',
  config = function ()
    vim.keymap.set('n', '<M-w>', function () vim.cmd('NeoNoName') end, {slient=true, noremap=true, nowait=true})
    -- If you are using bufferline.nvim
    -- vim.keymap.set('n', '<M-w>', function () vim.cmd('NeoNoNameBufferline') end, {slient=true, noremap=true, nowait=true})
  end
}
```


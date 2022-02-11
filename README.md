NeoNoName.lua
===

Layout preserving buffer deletion in Lua.


## Install & Usage

With the following function:
- press `<M-w>` once to swap-out the buffer from the existing window.
- press `<M-w>` twice to **really** delete that buffer.

```lua
use {
  'nyngwang/NeoNoName.lua',
  config = function ()
    vim.keymap.set('n', '<M-w>', function () vim.cmd('NeoNoName') end, {slient=true, noremap=true, nowait=true})
  end
}
```


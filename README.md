NeoNoName.lua
===

Layout preserving buffer deletion in Lua.


## Install & Usage

This plugin provides two *STRANGE* behaviours:
- call `NeoNoName` at non-`[No Name]`-buffer to simulate "remove the current buffer".
- call `NeoNoName` at `[No Name]`-buffer to delete the previous buffer.

Now, you can:

- call `NeoNoName` **twice** at any buffer you have finish working to really delete it.
- call `NeoNoName` **once** at any window to swap the buffer out, so you won't get distracted by the content of this buffer.


```lua
use {
  'nyngwang/NeoNoName.lua',
  config = function ()
    vim.keymap.set('n', '<M-w>', function () vim.cmd('NeoNoName') end, {slient=true, noremap=true, nowait=true})
  end
}
```


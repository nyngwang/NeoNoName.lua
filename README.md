NeoNoName.lua
===

Layout preserving buffer deletion in Lua.

## DEMO

https://user-images.githubusercontent.com/24765272/164238496-002d9388-f6c4-4697-ae55-d4e789c926f8.mov


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


NeoNoName.lua
===

Layout preserving buffer deletion in Lua.

## DEMO

https://user-images.githubusercontent.com/24765272/174682735-6112d411-c2bc-4fdb-86ba-b41e67ea198b.mov


## TL;DR

This plugin manages the only `[No Name]` buffer as a replacement to achieve layout-preserving buffer-deletion.


## Intro.

The main function of this plugin is `lua require('neo-no-name').neo_no_name(go_next)`,
where an optional function `go_next` can be provided to "go next" buffer in your way on deletion.

Two facts:
- call `neo_no_name(go_next)` at any buffer that is not `[No Name]`...
  - will remove duplicate `[No Name]` buffers if there are many. (This clean-up your buffer list)
  - will swap your current buffer with the `[No Name]` buffer. (will create one if it doesn't exist)
- call `neo_no_name(go_next)` again at the `[No Name]` buffer...
  - will jump to the buffer arrived by `go_next()` before that buffer got swapped out.
  - will delete the buffer that is swapped out.
    - by providing `go_next`, you can decide what's the next buffer on deletion.


### `setup` Options

#### `go_next_on_delete`, type `boolean`

*default: `true`*

whether or not to `go_next()` after you call `neo_no_name(go_next)` twice on the same window.


#### `should_skip`, type `function`

*default: `function return false end`*

For example, you can skip all terminal buffers on `go_next()`:

```lua
should_skip = function (c)
  return vim.api.nvim_buf_get_option(c.bufnr, 'bt') == 'terminal'
end,
```

where `c` is the context when you call `neo_no_name(go_next)`:

```lua
context = {
  bufnr = vim.api.nvim_get_current_buf()
}
```

Feel free to create an issue/PR telling about what you need.


#### `before_hooks`, type `{ function, ... }`

*default: `{}`*

You might want to avoid calling `go_next` on some situation.
In this case, you can call `abort()` in any function you provided by `before_hooks`:

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

where `u` provides some APIs to change the behavior of this plugin:

```
utils.abort: abort the current execution of `NeoNoName`.
```

Feel free to create an issue/PR telling about what you need.


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
      },
      go_next_on_delete = false, -- layout-preserving buffer deletion.
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

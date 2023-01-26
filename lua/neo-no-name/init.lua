local U = require('neo-no-name.utils')
---------------------------------------------------------------------------------------------------
local M = {}
local caller = nil
local buf_right = nil
local caller_is_terminal = false
local should_abort = false
local utils = {
  abort = function () should_abort = true end
}

---------------------------------------------------------------------------------------------------
function M.setup(opts)
  opts = opts or {}
  M.before_hooks = opts.before_hooks or {}
  M.should_skip = (type(opts.should_skip) == 'function' and type(opts.should_skip()) == 'boolean')
    and opts.should_skip
    or (function () return false end)
  M.go_next_on_delete = opts.go_next_on_delete and true
end


function M.neo_no_name_clean()
  if vim.bo.filetype == 'gitcommit' then return end
  U.ensure_only_one_no_name()
end


function M.neo_no_name(go_next)
  if go_next == nil then
    go_next = function () vim.cmd('bn') end
  end

  -- don't touch modified files as always.
  if vim.bo.modified then return end

  U.ensure_only_one_no_name()

  -- the second stage: if it's [No Name] then we should delete the previous buffer.
  if U.is_no_name_buf() then
    if buf_right == nil then return end

    if caller_is_terminal then
      vim.cmd('silent! bd! ' .. caller)
    else
      vim.cmd('silent! bd ' .. caller)
    end

    if buf_right ~= caller
      and M.go_next_on_delete then
      vim.api.nvim_set_current_buf(buf_right)
    end
    buf_right = nil
    return
  end

  -- the first stage: switch to the only [No Name].

  -- run pre_hooks.
  should_abort = false
  if type(M.before_hooks) == 'table' then
    for _, hook in pairs(M.before_hooks) do
      if type(hook) == 'function' then hook(utils) end
    end
  end
  if should_abort then return end

  caller = vim.api.nvim_get_current_buf()
  caller_is_terminal = vim.bo.buftype == 'terminal'

  repeat
    go_next()
  until
    vim.api.nvim_get_current_buf() == caller
    or not (U.is_no_name_buf() or M.should_skip())

  buf_right = vim.api.nvim_get_current_buf()

  vim.api.nvim_set_current_buf(U.give_me_a_no_name())
end


local function setup_vim_commands()
  vim.cmd [[
    command! NeoNoName lua require'neo-no-name'.neo_no_name()
    command! NeoNoNameClean lua require'neo-no-name'.neo_no_name_clean()
  ]]
end
setup_vim_commands()


return M

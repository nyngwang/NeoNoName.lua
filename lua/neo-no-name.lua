local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
---------------------------------------------------------------------------------------------------
local M = {}


function M.buffer_delete()
  if (vim.bo.filetype == 'dashboard') then
    vim.cmd('bd')
    return
  end
  local buffers = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted')
  end, vim.api.nvim_list_bufs())
  if (vim.api.nvim_tabpage_get_number(0) == 1) then
    if (#buffers > 1) then
      vim.cmd('bn')
      vim.cmd('bd #')
    else
      vim.cmd('bd')
    end
    return
  end
  local win_from_non_hidden_buf = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    win_from_non_hidden_buf[vim.api.nvim_win_get_buf(win)] = win
  end
  -- find a No-Name buffer from the existing ones in `:ls`.
  local first_no_name_buf = nil
  for _, buf in ipairs(buffers) do
    if (vim.api.nvim_buf_get_name(buf) == '') then
      first_no_name_buf = buf
      break
    end
  end
  -- if this is the first No Name buffer, then create one and done.
  if (first_no_name_buf == nil) then
    vim.cmd('enew')
    return
  end
  -- make the current buffer No Name without `:enew`, so both `buffers`, and `win_from_non_hidden_buf` are valid.
  vim.api.nvim_set_current_buf(first_no_name_buf)
  -- set all the other No Name buffers to be the same one.
  for _, buf in ipairs(buffers) do
    if (vim.api.nvim_buf_get_name(buf) == '' and win_from_non_hidden_buf[buf] ~= nil) then
      vim.api.nvim_win_set_buf(win_from_non_hidden_buf[buf], first_no_name_buf)
    end
  end
  -- delete all the other No-Name buffers.
  for _, buf in ipairs(buffers) do
    if (vim.api.nvim_buf_get_name(buf) == '' and buf ~= first_no_name_buf) then
      vim.cmd('bd ' .. buf)
    end
  end
end


local function setup_vim_commands()
  vim.cmd [[
    command! NeoNoName lua require'neo-no-name'.buffer_delete()
  ]]
end

setup_vim_commands()

return M

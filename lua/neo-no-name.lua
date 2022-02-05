local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
---------------------------------------------------------------------------------------------------
local M = {}

M.wins_from_non_hidden_buf = {}

local function get_all_valid_buffers()
  return vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted')
  end, vim.api.nvim_list_bufs())
end

local function create_map_wins_from_non_hidden_buf() -- by loop through all windows (visible for sure)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local cur_buf = vim.api.nvim_win_get_buf(win)
    if M.wins_from_non_hidden_buf[cur_buf] == nil then -- to satisfy assumption.
      M.wins_from_non_hidden_buf[cur_buf] = {}
    end
    table.insert(M.wins_from_non_hidden_buf[cur_buf], win)
  end
  return M.wins_from_non_hidden_buf
end

local function find_first_no_name_buf(buffers) -- find a No-Name buffer from the existing ones in `:ls`.
  for _, buf in ipairs(buffers) do
    if (vim.api.nvim_buf_get_name(buf) == '') then
      return buf
    end
  end
  return nil
end

local function is_loaded_with_no_name(win)
  return vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)) == ''
end
---------------------------------------------------------------------------------------------------
function M.neo_no_name()
  -- Prepare
  local buffers_valid = get_all_valid_buffers()
  M.wins_from_non_hidden_buf = create_map_wins_from_non_hidden_buf()
  local first_no_name_buf = find_first_no_name_buf(buffers_valid)

  if (first_no_name_buf == nil) then
    vim.cmd('enew')
    return
  end

  vim.api.nvim_set_current_buf(first_no_name_buf)
  -- Both `wins_from_non_hidden_buf`, `buffers_valid` are still valid.

  -- merge the other `[No Name]`-buffers to this one.
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if is_loaded_with_no_name(win) then -- use the only `[No Name]`-buffer instead.
      vim.api.nvim_win_set_buf(win, first_no_name_buf)
    end
  end

  -- delete all the other No-Name buffers.
  for _, buf in ipairs(buffers_valid) do
    if (vim.api.nvim_buf_get_name(buf) == '' and buf ~= first_no_name_buf) then
      vim.cmd('bd ' .. buf)
    end
  end
end

local function setup_vim_commands()
  vim.cmd [[
    command! NeoNoName lua require'neo-no-name'.neo_no_name()
  ]]
end

setup_vim_commands()

return M

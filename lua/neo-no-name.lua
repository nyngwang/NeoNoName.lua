local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
---------------------------------------------------------------------------------------------------
local M = {}
local caller = nil
local buf_right = nil
local caller_is_terminal = false

local function is_valid_listed_no_name_buf(buf)
  if buf == nil then buf = 0 end
  return
    vim.api.nvim_buf_is_valid(buf)
    and vim.api.nvim_buf_get_option(buf, 'buflisted')
    and vim.api.nvim_buf_get_option(buf, 'filetype') == ''
    and vim.api.nvim_buf_get_option(buf, 'buftype') == ''
    and vim.api.nvim_buf_get_name(buf) == ''
end

local function all_valid_listed_no_name_bufs()
  return vim.tbl_filter(is_valid_listed_no_name_buf, vim.api.nvim_list_bufs())
end

local function get_current_or_first_valid_listed_no_name_buf()
  local cur_buf = vim.api.nvim_get_current_buf()
  return is_valid_listed_no_name_buf(cur_buf) and cur_buf or all_valid_listed_no_name_bufs()[1]
end

local function keep_only_one_valid_listed_no_name()
  if vim.bo.filetype == 'gitcommit' then return end

  local cur_buf = vim.api.nvim_get_current_buf()

  if #all_valid_listed_no_name_bufs() == 0 then
    vim.cmd('enew')
    vim.api.nvim_set_current_buf(cur_buf)
    return
  end

  if #all_valid_listed_no_name_bufs() == 1 then return end

  local keep = get_current_or_first_valid_listed_no_name_buf()

  for _, buf in ipairs(all_valid_listed_no_name_bufs()) do
    if buf ~= keep then
      local buf_info = vim.fn.getbufinfo(buf)[1]
      for _, win in ipairs(buf_info.windows) do
        vim.api.nvim_win_set_buf(win, keep)
      end
      vim.cmd('silent! bd ' .. buf)
    end
  end
end
---------------------------------------------------------------------------------------------------
function M.neo_no_name_clean()
  keep_only_one_valid_listed_no_name()
end

function M.neo_no_name(cmd_bn, cmd_bp)
  if cmd_bn == nil then cmd_bn = 'bn' end
  if cmd_bp == nil then cmd_bp = 'bp' end

  keep_only_one_valid_listed_no_name()

  if is_valid_listed_no_name_buf() then
    if caller == nil then return end
    if caller_is_terminal then
      vim.cmd('silent! bd! ' .. caller)
    else
      vim.cmd('silent! bd ' .. caller)
    end
    if buf_right ~= nil then
      vim.api.nvim_set_current_buf(buf_right)
      if is_valid_listed_no_name_buf(buf_right) then vim.cmd(cmd_bn) end
    end
    return
  end

  if vim.bo.filetype == 'fzf' then
    vim.api.nvim_input('a<Esc>')
    return
  end

  caller = vim.fn.bufnr()
  caller_is_terminal = vim.bo.buftype == 'terminal'

  if #vim.fn.getbufinfo({ buflisted = 1 }) >= 3 then
    vim.cmd(cmd_bn)
    buf_right = vim.fn.bufnr()
    vim.cmd(cmd_bp)
  else
    buf_right = nil
  end

  vim.api.nvim_set_current_buf(get_current_or_first_valid_listed_no_name_buf())
end

local function setup_vim_commands()
  vim.cmd [[
    command! NeoNoName lua require'neo-no-name'.neo_no_name()
    command! NeoNoNameBufferline lua require'neo-no-name'.neo_no_name('BufferLineCycleNext', 'BufferLineCyclePrev')
    command! NeoNoNameClean lua require'neo-no-name'.neo_no_name_clean()
  ]]
end

setup_vim_commands()


return M

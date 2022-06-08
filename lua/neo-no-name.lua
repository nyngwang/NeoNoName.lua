local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
---------------------------------------------------------------------------------------------------
local M = {}
local caller = nil
local buf_right = nil
local caller_is_terminal = false

local function is_valid_and_listed(buf)
  if buf == nil then buf = 0 end
  return vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted')
end

local function all_valid_listed_buffers()
  return vim.tbl_filter(is_valid_and_listed, vim.api.nvim_list_bufs())
end

local function first_noname_from_valid_listed_buffers(buffers) -- find a No-Name buffer from the existing ones in `:ls`.
  if not buffers then
    buffers = all_valid_listed_buffers()
  end
  for _, buf in ipairs(buffers) do
    if (vim.api.nvim_buf_get_name(buf) == '') then
      return buf
    end
  end
  return nil
end

local function just_one_valid_listed_noname(keep)
  if vim.bo.filetype == 'gitcommit' then return end
  local cur_buf = vim.fn.bufnr()
  local first_noname_buf = first_noname_from_valid_listed_buffers()
  if first_noname_buf == nil then
    vim.cmd('enew')
    if is_valid_and_listed(cur_buf) then
      vim.api.nvim_set_current_buf(cur_buf)
    end
    return
  end
  if keep == nil then
    keep = first_noname_buf
  end

  for _, buf in ipairs(all_valid_listed_buffers()) do
    local buf_info = vim.fn.getbufinfo(buf)[1]
    if buf_info.name == '' and buf_info.bufnr ~= keep then
      for _, win in ipairs(buf_info.windows) do
        vim.api.nvim_win_set_buf(win, keep)
      end
      vim.cmd('silent! bd ' .. buf)
    end
  end
  vim.api.nvim_set_current_buf(cur_buf)
end
---------------------------------------------------------------------------------------------------
function M.neo_no_name_clean()
  just_one_valid_listed_noname()
end

function M.neo_no_name(cmd_bn, cmd_bp)
  if cmd_bn == nil then cmd_bn = 'bn' end
  if cmd_bp == nil then cmd_bp = 'bp' end

  if not is_valid_and_listed() then
    just_one_valid_listed_noname()
    vim.api.nvim_set_current_buf(first_noname_from_valid_listed_buffers())
    caller = nil
    buf_right = nil
    return
  end
  if vim.fn.bufname() == '' and vim.bo.filetype == '' then
    if caller == nil then return end
    if caller_is_terminal then
      vim.cmd('silent! bd! ' .. caller)
    else
      vim.cmd('silent! bd ' .. caller)
    end
    if buf_right ~= nil then
      vim.api.nvim_set_current_buf(buf_right)
      if vim.fn.bufname() == '' and vim.bo.filetype == '' then vim.cmd(cmd_bn) end
    end
    return
  end
  just_one_valid_listed_noname()
  caller = vim.fn.bufnr()
  caller_is_terminal = vim.bo.buftype == 'terminal'
  if #vim.fn.getbufinfo({ buflisted = 1 }) >= 3 then
    vim.cmd(cmd_bn)
    buf_right = vim.fn.bufnr()
    vim.cmd(cmd_bp)
  else
    buf_right = nil
  end
  vim.api.nvim_set_current_buf(first_noname_from_valid_listed_buffers())
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

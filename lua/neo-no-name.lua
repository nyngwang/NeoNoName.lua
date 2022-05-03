local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
---------------------------------------------------------------------------------------------------
local M = {}
local buf_right = nil



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
  if vim.bo.buftype == 'terminal'
    or vim.bo.filetype == 'gitcommit'
    then return end
  local cur_buf = vim.api.nvim_get_current_buf()
  local first_noname_buf = first_noname_from_valid_listed_buffers()
  if first_noname_buf == nil then
    vim.cmd('enew')
    vim.api.nvim_set_current_buf(cur_buf)
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

function M.neo_no_name()
  if is_valid_and_listed()
    and (vim.fn.bufname() == '' and vim.bo.filetype == '') then
    vim.cmd('silent! bd #')
    if buf_right ~= nil then
      vim.api.nvim_set_current_buf(buf_right)
      if vim.fn.bufname() == '' then vim.cmd('bn') end
    end
    return
  end
  just_one_valid_listed_noname()
  if #vim.fn.getbufinfo({ buflisted = 1 }) >= 3 then
    vim.cmd('bn')
    print('buf_right: ' .. vim.fn.bufnr())
    buf_right = vim.fn.bufnr()
    vim.cmd('bp')
  else
    buf_right = nil
  end
  vim.api.nvim_set_current_buf(first_noname_from_valid_listed_buffers())
end

local function setup_vim_commands()
  vim.cmd [[
    command! NeoNoName lua require'neo-no-name'.neo_no_name()
    command! NeoNoNameClean lua require'neo-no-name'.neo_no_name_clean()
  ]]
end

setup_vim_commands()

return M

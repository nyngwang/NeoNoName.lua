local M = {}


function M.is_no_name_buf(buf)
  if buf == nil then buf = 0 end
  return
    vim.api.nvim_buf_is_loaded(buf)
    and vim.api.nvim_buf_get_option(buf, 'buflisted')
    and vim.api.nvim_buf_get_name(buf) == ''
    and vim.api.nvim_buf_get_option(buf, 'buftype') == ''
    and vim.api.nvim_buf_get_option(buf, 'filetype') == ''
end


function M.all_no_name_bufs()
  return vim.tbl_filter(M.is_no_name_buf, vim.api.nvim_list_bufs())
end


function M.ensure_only_one_no_name()
  local cur_buf = vim.api.nvim_get_current_buf()

  -- case1
  if #M.all_no_name_bufs() == 0 then
    vim.cmd('enew')
    vim.api.nvim_set_current_buf(cur_buf)
    return
  end

  -- case2
  if #M.all_no_name_bufs() == 1 then return end

  -- case3
  local keep = M.give_me_a_no_name()
  for _, buf in pairs(M.all_no_name_bufs()) do
    if buf ~= keep then
      local buf_info = vim.fn.getbufinfo(buf)[1]
      for _, win in pairs(buf_info.windows) do
        vim.api.nvim_win_set_buf(win, keep)
      end
      vim.cmd('silent! bd ' .. buf)
    end
  end
end


function M.give_me_a_no_name()
  M.ensure_only_one_no_name()
  -- prefer the current [No Name] buffer.
  local cur_buf = vim.api.nvim_get_current_buf()
  return M.is_no_name_buf(cur_buf) and cur_buf or M.all_no_name_bufs()[1]
end


return M

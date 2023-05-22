if vim.fn.has('nvim-0.8') == 0 then
  return
end

if vim.g.loaded_neo_no_name ~= nil then
  return
end

require('neo-no-name')

vim.g.loaded_neo_no_name = 1

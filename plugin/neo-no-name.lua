if vim.version().minor < 5 then
  return
end

if vim.g.loaded_neononame_nvim ~= nil then
  return
end

require('neo-no-name')

vim.g.loaded_neononame_nvim = 1

-- nvim-hlslens - search overlay with line context
-- https://github.com/kevinhwang91/nvim-hlslens

vim.pack.add { 'https://github.com/kevinhwang91/nvim-hlslens' }

require('hlslens').setup {
  calm_down = true,
  nearest_only = false,
}

local hlslens = require('hlslens')
local function nkeymap(cmd)
  return function()
    local c = vim.v.count
    vim.cmd(string.format('normal! %s%s', c == 0 and '' or c, cmd))
    hlslens.start()
  end
end

vim.keymap.set('n', 'n', nkeymap('n'), { desc = 'Search forward with hlslens' })
vim.keymap.set('n', 'N', nkeymap('N'), { desc = 'Search backward with hlslens' })
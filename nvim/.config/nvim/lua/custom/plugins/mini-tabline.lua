-- mini.tabline - buffer strip above the editor
require('mini.tabline').setup {
  show_icons = vim.g.have_nerd_font, -- icons only if a Nerd Font is installed
}

-- Close the current buffer
vim.keymap.set('n', '<leader>bd', '<Cmd>bdelete<CR>', { desc = 'Buffer delete' })

-- Switch between buffers (click tabs in the tabline also works)
vim.keymap.set('n', '<Tab>', '<Cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-Tab>', '<Cmd>bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', ']b', '<Cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '[b', '<Cmd>bprevious<CR>', { desc = 'Previous buffer' })

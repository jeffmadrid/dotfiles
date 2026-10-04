-- vim-fugitive - Git integration (:Git, :G, :Git blame, etc.)
-- https://github.com/tpope/vim-fugitive

vim.pack.add { 'https://github.com/tpope/vim-fugitive' }

-- Open the fugitive git status window (the git UI in a split)
vim.keymap.set('n', '<leader>gg', '<Cmd>Git<CR>', { desc = 'Git (fugitive)' })

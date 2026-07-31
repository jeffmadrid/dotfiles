-- LazyGit integration (git UI in a floating terminal window)
-- https://github.com/kdheepak/lazygit.nvim

vim.pack.add { 'https://github.com/kdheepak/lazygit.nvim' }

vim.g.lazygit_floating_window_winblend = 0
vim.g.lazygit_floating_window_scaling_factor = 0.9
vim.g.lazygit_floating_window_border_chars = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }

vim.keymap.set('n', '<leader>gg', '<Cmd>LazyGit<CR>', { desc = 'LazyGit' })

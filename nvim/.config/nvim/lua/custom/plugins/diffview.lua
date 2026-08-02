-- Diffview - git diff and file history in a tabbed UI
-- https://github.com/sindrets/diffview.nvim

vim.pack.add {
  'https://github.com/sindrets/diffview.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
}

require('diffview').setup {}

-- Open the diff for the current change (falls back to current buffer)
vim.keymap.set('n', '<leader>gd', '<Cmd>DiffviewOpen<CR>', { desc = 'Diffview open' })

-- Close the diffview tab
vim.keymap.set('n', '<leader>gD', '<Cmd>DiffviewClose<CR>', { desc = 'Diffview close' })

-- Git history of the current file
vim.keymap.set('n', '<leader>gh', '<Cmd>DiffviewFileHistory %<CR>', { desc = 'Diffview file history' })

-- Diff HEAD against the default branch (origin/HEAD, falling back to main/master)
vim.keymap.set('n', '<leader>gb', function()
  local remote_head = vim.trim(vim.fn.system { 'git', 'symbolic-ref', 'refs/remotes/origin/HEAD' })
  local branch = vim.v.shell_error == 0 and remote_head:match 'refs/remotes/origin/(.+)' or nil
  if not branch then
    for _, name in ipairs { 'main', 'master' } do
      local ok = vim.fn.system { 'git', 'rev-parse', '--verify', '--quiet', 'refs/heads/' .. name }
      if vim.v.shell_error == 0 and ok ~= '' then
        branch = name
        break
      end
    end
  end
  if not branch then
    vim.notify('Could not determine default branch', vim.log.levels.ERROR)
    return
  end
  vim.cmd('DiffviewOpen HEAD...' .. branch)
end, { desc = 'Diffview: compare HEAD to default branch' })

-- Diffview - git diff and file history in a tabbed UI
-- diffview+ is the actively maintained fork:
-- https://github.com/dlyongemallo/diffview-plus.nvim
-- (Same `diffview` module and `:Diffview*` commands as the original.)

vim.pack.add { 'https://github.com/dlyongemallo/diffview-plus.nvim' }

-- Close the whole diffview, from any pane
local function close_diffview() require('diffview').close() end

require('diffview').setup {
  enhanced_diff_hl = true, -- subtle filler lines + correct add/delete colours
  use_icons = vim.g.have_nerd_font, -- file-type icons in the file tree
  view = {
    -- Unified single-page diff (diffview+'s diff1_inline layout): deletions and
    -- additions render in one window instead of side-by-side. Path shown in the
    -- winbar; diagnostics are hidden in the diff buffers to keep the view clean.
    default = { layout = 'diff1_inline', winbar_info = true, disable_diagnostics = true },
    file_history = { layout = 'diff1_inline', disable_diagnostics = true },
    merge_tool = { layout = 'diff3_mixed' },
    -- diff1_inline doesn't fold unchanged regions by default; enable it so the
    -- unified view keeps the collapsed-context behaviour.
    inline = { fold_unchanged = true },
  },
  file_panel = {
    listing_style = 'tree', -- nested tree, like GitHub's "Files changed"
    -- flatten_dirs groups directory chains that have a single subdir (e.g.
    -- 'lua/custom/plugins/') onto one line. Press 'f' in the panel to toggle.
    tree_options = { flatten_dirs = true, folder_statuses = 'only_folded' },
    win_config = { position = 'left', width = 34 },
  },
  file_history_panel = {
    win_config = { position = 'bottom', height = 14 },
  },
  keymaps = {
    -- 'q' closes the whole diffview, from the diff buffers and the panels
    view = {
      { 'n', 'q', close_diffview, { desc = 'Close diffview' } },
    },
    file_panel = {
      { 'n', 'q', close_diffview, { desc = 'Close diffview' } },
    },
    file_history_panel = {
      { 'n', 'q', close_diffview, { desc = 'Close diffview' } },
    },
  },
}

-- Filler lines: render as blank space instead of the default '-' dashes.
-- 'fold' is blanked too so folded regions show "+-- N lines: ..." without the
-- trailing run of dots used to pad the rest of the folded line.
vim.opt.fillchars:append { diff = ' ', fold = ' ' }

-- Open the diff for the current change (falls back to current buffer)
vim.keymap.set('n', '<leader>gd', '<Cmd>DiffviewOpen<CR>', { desc = 'Diffview open' })

-- Close the diffview tab
vim.keymap.set('n', '<leader>gD', '<Cmd>DiffviewClose<CR>', { desc = 'Diffview close' })

-- Git history of the current file
vim.keymap.set('n', '<leader>gh', '<Cmd>DiffviewFileHistory %<CR>', { desc = 'Diffview file history' })

-- Resolve the default branch (origin/HEAD, falling back to main/master)
local function default_branch()
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
  return branch
end

-- Commits ahead of the default branch
vim.keymap.set('n', '<leader>gM', function()
  local branch = default_branch()
  if not branch then
    vim.notify('Could not determine default branch', vim.log.levels.ERROR)
    return
  end
  vim.cmd('DiffviewFileHistory --range=' .. branch .. '..HEAD')
end, { desc = 'Diffview: commits ahead of default branch' })

-- Compare HEAD against the default branch
vim.keymap.set('n', '<leader>gm', function()
  local branch = default_branch()
  if not branch then
    vim.notify('Could not determine default branch', vim.log.levels.ERROR)
    return
  end
  vim.cmd('DiffviewOpen ' .. branch .. '..HEAD')
end, { desc = 'Diffview: compare with default branch' })

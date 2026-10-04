-- Diffview - git diff and file history in a tabbed UI
-- https://github.com/sindrets/diffview.nvim

vim.pack.add {
  'https://github.com/sindrets/diffview.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
}

-- Close the whole diffview, from any pane
local function close_diffview() require('diffview').close() end

require('diffview').setup {
  enhanced_diff_hl = true, -- subtle filler lines + correct add/delete colours per side
  use_icons = vim.g.have_nerd_font, -- file-type icons in the file tree
  view = {
    -- Side-by-side diff (like GitHub's "Split" view), path shown in the winbar.
    -- Diagnostics are hidden in the diff buffers to keep the view clean.
    default = { layout = 'diff2_horizontal', winbar_info = true, disable_diagnostics = true },
    file_history = { layout = 'diff2_horizontal', disable_diagnostics = true },
    merge_tool = { layout = 'diff3_mixed' },
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

-- Filler lines: render as blank space instead of the default '-' dashes
vim.opt.fillchars:append { diff = ' ' }

-- ---------------------------------------------------------------------------
-- GitHub-flavoured diff colours
-- ---------------------------------------------------------------------------
-- GitHub paints additions on a green wash and deletions on a red wash, with a
-- stronger tint on the individually changed words. Neovim's diff highlight
-- groups are global, so the per-side colours (old = red, new = green) are
-- applied through window-local 'winhl' in the autocmd below.
--
-- The values are GitHub's dark-theme diff colours (Primer) blended over the
-- gruvbox-material "hard" background (#1d2021). Tweak the hex values to taste.
local function apply_diff_highlights()
  local set = vim.api.nvim_set_hl

  -- Line-level backgrounds (global fallbacks / the "new" side)
  set(0, 'DiffAdd', { bg = '#203326' }) -- added line   (green wash)
  set(0, 'DiffDelete', { bg = '#3e2727' }) -- deleted line (red wash)
  set(0, 'DiffChange', { bg = '#213042' }) -- changed line (neutral hunk blue)

  -- Word-level tint (global fallback; remapped per side below)
  set(0, 'DiffText', { bg = '#24532f' })

  -- Per-side line backgrounds for *modified* lines
  set(0, 'DiffviewDiffChangeOld', { bg = '#3e2727' })
  set(0, 'DiffviewDiffChangeNew', { bg = '#203326' })

  -- Per-side word-level tints
  set(0, 'DiffviewDiffTextOld', { bg = '#753431' })
  set(0, 'DiffviewDiffTextNew', { bg = '#24532f' })

  -- Re-derive diffview's "add shown as delete" group from our DiffDelete
  pcall(function() require('diffview.hl').update_diff_hl() end)
end

apply_diff_highlights()

-- Re-apply after a colourscheme change (registered after diffview's own handler).
vim.api.nvim_create_autocmd('ColorScheme', { callback = apply_diff_highlights })

-- Point DiffChange/DiffText at the red/green variants depending on which pane
-- the window shows, so modified lines read like GitHub's split view.
vim.api.nvim_create_autocmd('User', {
  pattern = 'DiffviewDiffBufWinEnter',
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local ok, view = pcall(function() return require('diffview.lib').get_current_view() end)
    local layout = ok and view and view.cur_layout
    if not layout then return end

    local old
    if layout.a and layout.a.id == win then
      old = true
    elseif layout.b and layout.b.id == win then
      old = false
    else
      return
    end

    local function remap(from, to)
      local winhl = vim.wo[win].winhl
      local pat = from .. ':[^,]*'
      if winhl:find(pat) then
        winhl = winhl:gsub(pat, from .. ':' .. to)
      else
        winhl = winhl ~= '' and (winhl .. ',' .. from .. ':' .. to) or (from .. ':' .. to)
      end
      vim.wo[win].winhl = winhl
    end

    remap('DiffChange', old and 'DiffviewDiffChangeOld' or 'DiffviewDiffChangeNew')
    remap('DiffText', old and 'DiffviewDiffTextOld' or 'DiffviewDiffTextNew')
  end,
})

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

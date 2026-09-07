-- fzf-lua setup, keymaps, LSP picker mappings
-- ============================================================
-- [[ Fuzzy Finder (files, lsp, etc) ]]
--
-- fzf-lua is a fuzzy finder built around the native `fzf` binary.
--  It can fuzzy find files, buffers, LSP symbols, git data, and more!
--  See `:help fzf-lua` for details.
--
-- The easiest way to use fzf-lua, is to start by doing something like:
--  :FzfLua helptags
--
-- Two important keymaps to use while in fzf-lua are:
--  - <F1>: show all keymaps for the current picker
--  - <F2>: toggle fullscreen
--
-- fzf-lua requires the `fzf` binary (brew install fzf); `fd` and `rg`
--  are used for faster file/grep collection when available.

vim.pack.add { 'https://github.com/ibhagwan/fzf-lua' }

-- See `:help fzf-lua` for all available options
require('fzf-lua').setup {
  -- Mirror the nerd-font setting so icons only render with a Nerd Font installed
  defaults = {
    file_icons = vim.g.have_nerd_font,
    color_icons = vim.g.have_nerd_font,
  },
  -- Use fzf-lua as the UI for `vim.ui.select` (like telescope-ui-select)
  ui_select = {},
  winopts = {
    width = 0.95,
    height = 0.95,
  },
}

local fzf_lua = require 'fzf-lua'

-- Scope a picker to the directory of the node under nvim-tree's cursor when
-- the tree is focused, otherwise use fzf-lua's default (git root / cwd).
local function tree_search()
  return require('custom.plugins.nvim-tree').tree_search_dir()
end

-- True when `dir` (or cwd) is inside a git work tree.
local function in_git_repo(dir)
  local out = vim.system({ 'git', '-C', dir or vim.uv.cwd(), 'rev-parse', '--is-inside-work-tree' }, { text = true }):wait()
  return out.code == 0 and vim.trim(out.stdout) == 'true'
end

vim.keymap.set('n', '<leader>sh', fzf_lua.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', fzf_lua.keymaps, { desc = '[S]earch [K]eymaps' })
-- <leader>sf: git-tracked (+ untracked, minus ignored) files via `git ls-files`.
-- Falls back to a plain file search outside of a git repository.
vim.keymap.set('n', '<leader>sf', function()
  local cwd = tree_search()
  local opts = cwd and { cwd = cwd } or {}
  if in_git_repo(cwd) then
    opts.cmd = 'git ls-files --cached --others --exclude-standard --deduplicate'
    fzf_lua.git_files(opts)
  else
    fzf_lua.files(opts)
  end
end, { desc = '[S]earch git [F]iles' })
-- <leader>sF: every file `fd`/`rg` can see (still honours .gitignore by default,
-- but works outside git repos and includes files git does not track).
vim.keymap.set('n', '<leader>sF', function()
  local cwd = tree_search()
  if cwd then fzf_lua.files { cwd = cwd } else fzf_lua.files() end
end, { desc = '[S]earch all [F]iles' })
vim.keymap.set('n', '<leader>ss', fzf_lua.builtin, { desc = '[S]earch [S]elect fzf-lua' })
vim.keymap.set('n', '<leader>sw', function()
  local cwd = tree_search()
  if cwd then fzf_lua.grep_cword { cwd = cwd } else fzf_lua.grep_cword() end
end, { desc = '[S]earch current [W]ord' })
vim.keymap.set('v', '<leader>sw', function()
  local cwd = tree_search()
  if cwd then fzf_lua.grep_visual { cwd = cwd } else fzf_lua.grep_visual() end
end, { desc = '[S]earch selected [W]ord' })
vim.keymap.set('n', '<leader>sg', function()
  local cwd = tree_search()
  if cwd then fzf_lua.live_grep { cwd = cwd } else fzf_lua.live_grep() end
end, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', fzf_lua.diagnostics_document, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', fzf_lua.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', fzf_lua.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sc', fzf_lua.commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader><leader>', fzf_lua.buffers, { desc = '[ ] Find existing buffers' })

-- Add fzf-lua based LSP pickers when an LSP attaches to a buffer.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('fzf-lua-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf

    -- Find references for the word under your cursor.
    vim.keymap.set('n', 'grr', fzf_lua.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

    -- Jump to the implementation of the word under your cursor.
    -- Useful when your language has ways of declaring types without an actual implementation.
    vim.keymap.set('n', 'gri', fzf_lua.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

    -- Jump to the definition of the word under your cursor.
    -- This is where a variable was first declared, or where a function is defined, etc.
    -- To jump back, press <C-t>.
    vim.keymap.set('n', 'grd', fzf_lua.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

    -- Fuzzy find all the symbols in your current document.
    -- Symbols are things like variables, functions, types, etc.
    vim.keymap.set('n', 'gO', fzf_lua.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

    -- Fuzzy find all the symbols in your current workspace.
    -- Similar to document symbols, except searches over your entire project.
    vim.keymap.set('n', 'gW', fzf_lua.lsp_live_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

    -- Jump to the type of the word under your cursor.
    -- Useful when you're not sure what type a variable is and you want to see
    -- the definition of its *type*, not where it was *defined*.
    vim.keymap.set('n', 'grt', fzf_lua.lsp_typedefs, { buffer = buf, desc = '[G]oto [T]ype Definition' })
  end,
})

-- Fuzzily search in the current buffer
vim.keymap.set('n', '<leader>/', fzf_lua.blines, { desc = '[/] Fuzzily search in current buffer' })

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>sn', function() fzf_lua.files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })

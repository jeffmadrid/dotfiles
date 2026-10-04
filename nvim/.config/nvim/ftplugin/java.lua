-- Java language server (Eclipse JDT LS) via nvim-jdtls.
-- Generic LSP keymaps live in init.lua's LspAttach autocmd; the jdtls-specific
-- `:Jdt*` commands are registered automatically by nvim-jdtls.

if vim.fn.executable 'java' == 0 then
  vim.notify('[jdtls] Java runtime not found; install a JDK (21+) to use the Java language server', vim.log.levels.ERROR)
  return
end
if vim.fn.executable 'jdtls' == 0 then
  vim.notify('[jdtls] jdtls executable not found; run :MasonInstall jdtls', vim.log.levels.ERROR)
  return
end

local ok, jdtls = pcall(require, 'jdtls')
if not ok then
  vim.notify('[jdtls] nvim-jdtls is not available yet; run :lua vim.pack.update() or restart Neovim', vim.log.levels.ERROR)
  return
end

-- Find the project root directory
local root_markers = {
  '.git',
  'mvnw',
  'gradlew',
  'pom.xml',
  'build.gradle',
  'build.gradle.kts',
  'settings.gradle',
  'settings.gradle.kts',
}
local root_dir = require('jdtls.setup').find_root(root_markers)
if not root_dir then
  -- Fall back to the buffer's directory so standalone/single-file Java sources
  -- still get basic language support.
  local buf_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  if buf_dir then
    root_dir = buf_dir
    vim.notify('[jdtls] No project root found; using ' .. root_dir, vim.log.levels.INFO)
  end
end
if not root_dir then return end

-- Set up a per-project workspace to keep indexes separate. The path hash keeps
-- projects with the same directory name from sharing (and corrupting) a workspace.
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = vim.fn.stdpath 'data' .. '/site/workspace/' .. project_name .. '-' .. vim.fn.sha256(root_dir):sub(1, 8)

-- The command to start the language server
local config = {
  cmd = {
    'jdtls',
    '-data',
    workspace_dir,
  },
  root_dir = root_dir,
  -- Give jdtls the same completion capabilities as every other LSP server.
  -- nvim-jdtls calls vim.lsp.start() directly, so blink.cmp's `vim.lsp.config('*')`
  -- wildcard is not applied automatically.
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  settings = {
    java = {
      signatureHelp = { enabled = true },
      rename = { enabled = true },
    },
  },
}

-- Attach to the current buffer
jdtls.start_or_attach(config)

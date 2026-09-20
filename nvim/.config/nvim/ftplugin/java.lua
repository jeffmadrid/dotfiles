local jdtls = require('jdtls')

-- Find the project root directory
local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
local root_dir = require('jdtls.setup').find_root(root_markers)
if not root_dir then return end

-- Set up a per-project workspace to keep indexes separate
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = vim.fn.stdpath('data') .. '/site/workspace/' .. project_name

-- The command to start the language server
local config = {
  cmd = {
    'jdtls',
    '-data', workspace_dir,
  },
  root_dir = root_dir,
  -- Additional settings can go here
  settings = {
    java = {
      signatureHelp = { enabled = true },
      import = { enabled = true },
      rename = { enabled = true },
    },
  },
}

-- Attach to the current buffer
jdtls.start_or_attach(config)

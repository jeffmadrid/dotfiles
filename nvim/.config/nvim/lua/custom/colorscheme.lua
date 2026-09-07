-- Colorscheme configuration
-- Gruvbox Material with hard contrast

-- Helper for GitHub URLs
local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add { gh 'f4z3r/gruvbox-material.nvim' }
---@diagnostic disable-next-line: missing-fields
require('gruvbox-material').setup {
  contrast = 'hard', -- hard contrast variant
  italics = false,   -- Disable italics in comments
}

-- Load the colorscheme
vim.cmd.colorscheme 'gruvbox-material'
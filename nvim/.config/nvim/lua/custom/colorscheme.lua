-- Colorscheme configuration
-- Gruvbox with hard contrast
-- https://github.com/ellisonleao/gruvbox.nvim

-- Helper for GitHub URLs
local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add { gh 'ellisonleao/gruvbox.nvim' }
require('gruvbox').setup {
  contrast = 'hard', -- hard contrast variant
}

-- Load the colorscheme
vim.o.background = 'dark'
vim.cmd.colorscheme 'gruvbox'

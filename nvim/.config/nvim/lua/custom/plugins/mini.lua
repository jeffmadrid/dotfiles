-- mini.ai - better Around/Inside textobjects (a, i)
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]paren
--  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
--  - ci'  - [C]hange [I]nside [']quote
require('mini.ai').setup {
  -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
}

-- mini.move - move any selection or line in any direction
--
-- Examples (defaults are Alt/Meta + hjkl):
--  - <M-h>/<M-l> - move selection/line left/right
--  - <M-j>/<M-k> - move selection/line down/up
require('mini.move').setup {
  options = {
    -- Automatically reindent during vertical linewise moves (default)
    reindent_linewise = true,
  },
}

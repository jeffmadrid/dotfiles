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

-- mini.pairs - automatic brackets and quotes
--
-- Examples:
--  - (   - inserts () and puts cursor between them
--  - )   - inserts ) (or jumps over it if already there)
--  - '   - toggles '' with cursor inside
require('mini.pairs').setup()

-- mini.indentscope - visualize and operate on the current indent scope
--
-- Examples:
--  - ii  - select the scope's body
--  - ai  - select the scope including its border line(s)
--  - [i  - jump to scope's top
--  - ]i  - jump to scope's bottom
require('mini.indentscope').setup()


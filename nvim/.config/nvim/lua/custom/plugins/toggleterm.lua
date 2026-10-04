vim.pack.add { 'https://github.com/akinsho/toggleterm.nvim' }

require('toggleterm').setup {
  size = 20,
  open_mapping = [[<C-`>]],
  direction = 'float',
  float_opts = {
    border = 'curved',
    width = function() return math.floor(vim.o.columns * 0.90) end,
    height = function() return math.floor(vim.o.lines * 0.90) end,
  },
  start_in_insert = true,
  close_on_exit = true,
}

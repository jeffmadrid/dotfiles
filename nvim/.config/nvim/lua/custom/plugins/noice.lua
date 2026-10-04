vim.pack.add {
  { src = 'https://github.com/folke/noice.nvim' },
  { src = 'https://github.com/MunifTanjim/nui.nvim' },
}

require('noice').setup {
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = true,
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = false,
  },
  cmdline = {
    enabled = true,
    view = 'cmdline_popup',
    format = {
      cmdline = { pattern = '^:', icon = '', lang = 'vim' },
      search_down = { kind = 'search', pattern = '^/', icon = ' ', lang = 'regex' },
      search_up = { kind = 'search', pattern = '^%?', icon = ' ', lang = 'regex' },
      filter = { pattern = '^:%s*!', icon = '$', lang = 'bash' },
      lua = { pattern = '^:%s*lua%s+', icon = '', lang = 'lua' },
      help = { pattern = '^:%s*he?l?p?%s+', icon = '' },
      input = {},
    },
  },
  messages = {
    enabled = true,
    view = 'mini',
    view_error = 'mini',
    view_warn = 'mini',
    view_history = 'messages',
    view_search = 'virtualtext',
  },
  popupmenu = {
    enabled = true,
    backend = 'nui',
    kind_icons = {},
  },
  redirect = {
    view = 'popup',
    filter = { event = 'msg_show' },
  },
  commands = {
    history = {
      view = 'split',
      opts = { enter = true, format = 'details' },
      filter = { any = { { event = 'msg_show' }, { event = 'notify' } } },
    },
    last = {
      view = 'popup',
      opts = { enter = true, format = 'details' },
      filter = { any = { { event = 'msg_show' }, { event = 'notify' } } },
    },
    errors = {
      view = 'popup',
      opts = { enter = true, format = 'details' },
      filter = { event = 'msg_show', kind = 'error' },
    },
  },
  views = {
    cmdline_popup = {
      border = {
        style = 'none',
        padding = { 1, 1 },
      },
    },
  },
}

vim.keymap.set('n', '<leader>nn', '<cmd>Noice dismiss<cr>', { desc = 'Dismiss Noice notifications' })
vim.keymap.set('n', '<leader>nh', '<cmd>Noice history<cr>', { desc = 'Noice history' })
vim.keymap.set('n', '<leader>nl', '<cmd>Noice last<cr>', { desc = 'Noice last message' })
vim.keymap.set('n', '<leader>ne', '<cmd>Noice errors<cr>', { desc = 'Noice errors' })

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Auto-save settings
vim.o.auto_rewind = true
vim.o.auto_save_on_join = true

-- Clear highlights on search when pressing <Esc> in normal mode

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Auto-save idle timer: save after 60 seconds of inactivity
vim.api.nvim_create_autocmd('Timer', {
  interval = 1,
  callback = function()
    local last_save = vim.o.last_save_time or 0
    local now = os.time()
    if now - last_save > 60 then
      vim.fn.save_all()
      vim.o.last_save_time = now
    end
  end,
})

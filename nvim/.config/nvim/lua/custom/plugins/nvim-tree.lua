-- Nvim-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-tree/nvim-tree.lua

vim.pack.add {
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/nvim-tree/nvim-web-devicons',
}

vim.keymap.set('n', '\\', '<Cmd>NvimTreeFindFile<CR>', { desc = 'NvimTree reveal', silent = true })
vim.keymap.set('n', '<leader>e', '<Cmd>NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })

-- Use a single full-width statusline spanning all windows.
vim.o.laststatus = 3

local M = {}

local function is_tree_win(win)
  local buf = vim.api.nvim_win_get_buf(win)
  return vim.bo[buf].filetype == 'NvimTree'
end

-- Directory of the node under the tree's cursor, so fzf-lua searches can be
-- scoped to it. Returns nil when the tree isn't focused or the node is the root.
function M.tree_search_dir()
  if not is_tree_win(vim.api.nvim_get_current_win()) then return nil end
  local ok, node = pcall(require('nvim-tree.api').tree.get_node_under_cursor)
  if not ok or not node or not node.absolute_path then return nil end
  if node.type == 'directory' then return node.absolute_path end
  if node.parent and node.parent.absolute_path then return node.parent.absolute_path end
  return nil
end

-- Render the main buffer's statusline, so the single full-width statusline
-- keeps showing the main buffer even while the nvim-tree window is focused.
function M.main_statusline()
  local actual = vim.g.actual_curwin
  local win
  if type(actual) == 'number' and actual ~= 0 and vim.api.nvim_win_is_valid(actual) and not is_tree_win(actual) then
    win = actual
  else
    local alt = vim.fn.win_getid(vim.fn.winnr '#')
    if alt ~= 0 and vim.api.nvim_win_is_valid(alt) and not is_tree_win(alt) then
      win = alt
    else
      local tab = vim.api.nvim_win_get_tabpage(0)
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_tabpage(w) == tab and not is_tree_win(w) then
          win = w
          break
        end
      end
    end
  end
  if not win then return '' end
  return vim.api.nvim_win_call(win, function()
    return vim.api.nvim_eval_statusline(require('mini.statusline').active(), {}).str
  end)
end

vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = 'NvimTree_*',
  callback = function(ev)
    local win = vim.fn.bufwinid(ev.buf)
    if win ~= -1 then
      vim.api.nvim_win_set_option(win, 'statusline', '%!v:lua.require("custom.plugins.nvim-tree").main_statusline()')
    end
  end,
})

require('nvim-tree').setup {
  renderer = {
    group_empty = true, -- group directories with a single child
  },
}

return M

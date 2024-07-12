-- Iron.nvim detects code blocks in the current file using textobjects, sends them to the REPL in the terminal, and executes them.
-- For non-terminal REPLs such as Jupyter Notebook, tools like Jupynium are needed to send execute commands.
-- Therefore, the following keybindings allow switching between the default REPL tool (Iron.nvim) and other specialized REPL tools like Jupynium.

-- Buffer remapping for default REPL (Iron.nvim)
-- Reference: ~/.config/lvim/after/ftplugin/python.lua
-- if vim.b.CURRENT_REPL == nil then
--   vim.b.CURRENT_REPL = "REPL:default"
--   vim.keymap.set('n', '[w', ':norm strah<cr>', { buffer = true, silent = true })
--   vim.keymap.set('n', ']w', ':norm strih<cr>', { buffer = true, silent = true })
-- end

-- Set more remapping for different filetypes.
-- This can be set in ~/.config/lvim/after/ftplugin/[*other_filetype*].lua
-- The configuration should be same to the example above.


-- NOTE: Which-key mappings for different filetype REPLs (below is for Jupynium REPL in Python).
-- Using the `repl_types` table to register REPL settings
-- for the global function `select_repl_type` to switch between
-- Iron.nvim (default REPL execution tool) and different filetype REPLs (special REPL execution, such as Jupynium).
lvim.builtin.which_key.mappings['rj'] = {
  name = "jupynium",
  a = { "<cmd>JupyniumStartAndAttachToServer<cr>", "Jupynium Start and Attach Server" },
  s = { "<cmd>JupyniumStartSync<cr>", "Jupynium Sync .py to notebook .ipynb" },
  d = { "<cmd>JupyniumStopSync<cr>", "Jupynium Stop Sync" },
  w = { "<cmd>JupyniumExecuteSelectedCells<cr>", "Jupynium Execute Current Cell" },
  c = { "<cmd>JupyniumClearSelectedCellsOutputs<cr>", "Jupynium Clear Cell Output" },
  r = { "<cmd>JupyniumKernelRestart<cr>", "Jupynium Kernel Restart" },
  i = { "<cmd>JupyniumKernelInterrupt<cr>", "Jupynium Kernel Interrupt" },
  [":"] = { "<cmd>lua select_repl_type()<cr>", "REPL cell execute to Jupynium (remap ]w [w)" },
  [";"] = { "<cmd>lua select_repl_type()<cr>", "REPL cell execute to Jupynium (remap ]w [w)" },
}


-- NOTE: Function to register the remapping for different filetype REPLs.
-- Use the `repl_types` table to expand the specialized REPLs.
local repl_types = {
  {
    name = "default",
    remap_setting = function()
      vim.b.CURRENT_REPL = "REPL:default"
      vim.keymap.set('n', '[w', ':norm strah<cr>', { buffer = true, silent = true })
      vim.keymap.set('n', ']w', ':norm strih<cr>', { buffer = true, silent = true })
    end
  },
  {
    name = "jupynium",
    remap_setting = function()
      vim.b.CURRENT_REPL = "REPL:jupynium"
      vim.keymap.set('n', '[w', ':JupyniumExecuteSelectedCells<CR>', { buffer = true, silent = true })
      vim.keymap.set('n', ']w', ':JupyniumExecuteSelectedCells<CR>', { buffer = true, silent = true })
    end
  }
  -- Add more specialized REPLs here.
}

local function REPL_Remap_Register(selection)
  for _, repl_type in ipairs(repl_types) do
    if repl_type.name == selection.value then
      vim.b.CURRENT_REPL = "REPL:" .. selection.value
      repl_type.remap_setting()
      return
    end
  end
end

-- NOTE: Global REPL switch function.
-- This can be expanded to switch between Iron.nvim and other specialized REPLs.
-- Use the `repl_types` table for expansion.
function select_repl_type()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  pickers.new({}, {
    prompt_title = 'Select REPL Type',
    finder = finders.new_table({
      results = repl_types,
      entry_maker = function(entry)
        return {
          value = entry.name,
          display = entry.name,
          ordinal = entry.name,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          REPL_Remap_Register(selection)
        end
      end)
      return true
    end,
  }):find()
end

-- Bind the function to a command
vim.api.nvim_set_keymap('n', '<leader>s:', ':lua select_repl_type()<cr>', { noremap = true, silent = true })

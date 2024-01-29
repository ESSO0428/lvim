local actions = require('telescope.actions')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local action_state = require('telescope.actions.state')

function select_current_nvim_jupyter_kernel_in_current_buffer()
  local neovim_pid = vim.fn.getpid()
  local neovim_sub_pids = vim.fn.systemlist("pgrep -P " .. neovim_pid)

  local kernel_names = {}
  for _, pid in ipairs(neovim_sub_pids) do
    local cmdline = vim.fn.systemlist("ps -p " .. pid .. " -o cmd=")
    if string.find(cmdline[1], "jupyter%-console") then
      local kernel_pids = vim.fn.systemlist("pgrep -P " .. pid)
      for _, kpid in ipairs(kernel_pids) do
        local kcmdline = vim.fn.systemlist("ps -p " .. kpid .. " -o cmd=")
        if string.find(kcmdline[1], "ipykernel_launcher") then
          local kernel_name = string.match(kcmdline[1], "ipykernel_launcher%s+-f%s+.+/(kernel%-[0-9]+%.json)")
          if kernel_name then
            table.insert(kernel_names, kernel_name)
          end
        end
      end
    end
  end

  if #kernel_names > 0 then
    pickers.new({}, {
      prompt_title = 'Select Jupyter Kernel (Current nvim)',
      finder = finders.new_table({
        results = kernel_names,
      }),
      sorter = require('telescope.config').values.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          local bufnr = vim.api.nvim_get_current_buf()
          local selected_kernel_name = selection[1]
          vim.api.nvim_buf_set_var(bufnr, "jupyter_kernel", selected_kernel_name)
          vim.cmd('JupyterAttach ' .. selected_kernel_name)
        end)
        return true
      end,
    }):find()
  end
end

vim.api.nvim_create_user_command("SelectCurrentNvimActJupyterKernel",
  select_current_nvim_jupyter_kernel_in_current_buffer, {})
lvim.builtin.which_key.mappings.s.q = { "<cmd>SelectCurrentNvimActJupyterKernel<CR>",
  "Check Jupyter Kernel (Current nvim)" }

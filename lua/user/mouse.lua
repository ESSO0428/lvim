local M = {}
vim.cmd [[:amenu 10.100 PopUp.Code\ Actions <cmd>:lua require('actions-preview').code_actions()<CR>]]
vim.cmd [[:amenu 10.110 PopUp.Breakpoint\ Toggle <cmd>:lua require('persistent-breakpoints.api').toggle_breakpoint()<CR>]]
vim.cmd [[:amenu 10.120 PopUp.-sep1- *]]
vim.cmd [[:amenu 10.130 PopUp.List\ Breakpoints <cmd>:lua require'telescope'.extensions.dap.list_breakpoints()<CR>]]
vim.cmd [[:amenu 10.140 PopUp.-sep2- *]]
vim.cmd [[:amenu 10.150 PopUp.Condition\ Breakpoint <cmd>:popup Condition Breakpoint<CR>]]
vim.cmd [[:amenu 10.160 Condition\ Breakpoint.Condition\ \+\ Breakpoint <cmd>:lua require('persistent-breakpoints.api').set_breakpoint(vim.fn.input('Breakpoint condition: '), vim.fn.input('Hit condition: '), nil)<CR>]]
vim.cmd [[:amenu 10.170 Condition\ Breakpoint.Condition\ \+\ Logpoint <cmd>:lua require('persistent-breakpoints.api').set_breakpoint(vim.fn.input('Breakpoint condition: '), vim.fn.input('Hit condition: '), vim.fn.input('Log point message: '))<CR>]]
vim.cmd [[:amenu 10.180 Condition\ Breakpoint.-sep2_1- *]]
vim.cmd [[:amenu 10.190 Condition\ Breakpoint.Edit\ Breakpoint <cmd>:DAPEditBreakpoint<CR>]]
vim.cmd [[:amenu 10.200 PopUp.Clear\ All\ Breakpoints <cmd>:lua require('persistent-breakpoints.api').clear_all_breakpoints()<CR>]]
vim.cmd [[:amenu 10.210 PopUp.-sep3- *]]
vim.cmd [[:amenu 10.220 PopUp.Color\ Picker <cmd>:lua require("minty.huefy").open()<CR>]]
vim.cmd [[:amenu 10.230 PopUp.-sep4- *]]

function M.setup()
  -- NOTE: Plugin of Developmenting, so only use in NvimTree
  -- mouse users + nvimtree users!
  local nvimtree_memu_options = require("menus.nvimtree")
  -- Search and replace the cmd of "Open in terminal" in nvimtree_memu_options
  for i, item in ipairs(nvimtree_memu_options) do
    if item.name == "  Open in terminal" then
      require("menus.nvimtree")[i].cmd = function() horizontal_term() end
      break
    end
  end
end

vim.keymap.set("n", "<RightMouse>",
  function()
    vim.cmd.exec '"normal! \\<RightMouse>"'

    local options = vim.bo.ft == "NvimTree" and "nvimtree" or "default"
    if options == "default" then
      options = {
        {
          name = "Code Actions",
          cmd = function()
            require('actions-preview').code_actions()
          end,
          rtxt = "<leader>ua",
        },
        {
          name = "Toggle Breakpoint",
          cmd = function()
            require('persistent-breakpoints.api').toggle_breakpoint()
          end,
          rtxt = "<leader>\\",
        },
        { name = "separator" },
        {
          name = "List Breakpoints",
          cmd = function()
            require 'telescope'.extensions.dap.list_breakpoints()
          end,
          rtxt = "<leader>sb",
        },
        { name = "separator" },
        {
          name = "Condition Breakpoint",
          items = {
            {
              name = "Condition + Breakpoint",
              cmd = function()
                require('persistent-breakpoints.api').set_breakpoint(
                  vim.fn.input('Breakpoint condition: '),
                  vim.fn.input('Hit condition: '),
                  nil
                )
              end,
              rtxt = "<leader>dlc",
            },
            {
              name = "Condition + Logpoint",
              cmd = function()
                require('persistent-breakpoints.api').set_breakpoint(
                  vim.fn.input('Breakpoint condition: '),
                  vim.fn.input('Hit condition: '),
                  vim.fn.input('Log point message: ')
                )
              end,
              rtxt = "<leader>dll",
            },
            { name = "separator" }, -- 加入分隔線，保持原有結構
            {
              name = "Edit Breakpoint",
              cmd = function()
                vim.api.nvim_command("DAPEditBreakpoint")
              end,
              rtxt = "<leader>dle",
            }
          }
        },
        { name = "separator" },
        {
          name = "Clear All Breakpoints",
          cmd = function()
            require('persistent-breakpoints.api').clear_all_breakpoints()
          end,
          rtxt = "<leader>d\\",
        },
        { name = "separator" },
        {
          name = "  Lsp Actions",
          hl = "Exblue",
          items = "lsp",
        },
        { name = "separator" },
        {
          name = "  Open in terminal",
          hl = "ExRed",
          cmd = function()
            local old_buf = require("menu.state").old_data.buf
            local old_bufname = vim.api.nvim_buf_get_name(old_buf)
            local old_buf_dir = vim.fn.fnamemodify(old_bufname, ":h")

            local cmd = "cd " .. old_buf_dir

            -- base46_cache var is an indicator of nvui user!
            if vim.g.base46_cache then
              require("nvchad.term").new { cmd = cmd, pos = "sp" }
            else
              ToggleTermExec('horizontal')
            end
          end,
        },
        { name = "separator" },
        {
          name = "Copy Content",
          cmd = "%y+",
          rtxt = "<C-c>",
        },
        {
          name = "Delete Content",
          cmd = "%d",
          rtxt = "dc",
        },
        { name = "separator" },
        {
          name = "  Color Picker",
          cmd = function()
            require("minty.huefy").open()
          end,
        },
      }
    end
    require("menu").open(options, { mouse = true })
  end,
  { silent = true, noremap = true }
)

return M

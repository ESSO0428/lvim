vim.g.ipy_celldef = "^# %%"
vim.g.jupytext_fmt = "py"
vim.g.jupytext_style = "hydrogen"
vim.g.nvim_ipy_perform_mappings = 0

vim.api.nvim_create_user_command("RunQtConsole", function()
  local current_dir = vim.fn.expand("%:p:h")
  local cmd = "cd " .. current_dir .. "; jupyter qtconsole --JupyterWidget.include_other_output=True --style monokai"
  vim.fn.jobstart(cmd)
end, {})

-- lvim.keys.normal_mode["'q"] = { "<cmd>RunQtConsole<cr>gg", desc = "Run QtConsole" }
-- lvim.keys.normal_mode["\\E"] = { "<cmd>IronRepl<cr>", desc = "Open REPL" }
-- lvim.keys.normal_mode["\\w"] = { "<cmd>IPython --existing --no-window<cr><Plug>(IPy-RunCell)", desc = "Run Cell" }
-- lvim.keys.normal_mode["\\e"] = { "<cmd>IPython --existing --no-window<cr><Plug>(IPy-RunAll)", desc = "Run All" }

-- lvim.keys.normal_mode["[w"] = { "strah", desc = "Send Line Above" }
-- lvim.keys.normal_mode["]w"] = { "stR", desc = "Send Line Below" }
-- lvim.keys.normal_mode["[r"] = { "stR", desc = "Send Line Above" }
-- lvim.keys.normal_mode["]r"] = { "stR", desc = "Send Line Below" }
-- lvim.keys.normal_mode["[R"] = { "stR", desc = "Send Line Above" }
-- lvim.keys.normal_mode["]R"] = { "stR", desc = "Send Line Below" }
-- lvim.keys.visual_mode["[w"] = { "str", desc = "Send Selection Above" }
-- lvim.keys.visual_mode["]w"] = { "str", desc = "Send Selection Below" }
-- lvim.keys.visual_mode["[r"] = { "str", desc = "Send Selection Above" }
-- lvim.keys.visual_mode["]r"] = { "str", desc = "Send Selection Below" }

return {
  {
    "GCBallesteros/vim-textobj-hydrogen",
    dependencies = {
      { "kana/vim-textobj-line", dependencies = { "kana/vim-textobj-user" } },
    }
  },
  -- { "bfredl/nvim-ipy" },
  { "ESSO0428/nvim-ipy" },
  {
    "ESSO0428/iron.nvim",
    config = function()
      local iron = require("iron.core")
      local view = require("iron.view")
      iron.setup({
        config = {
          repl_open_cmd = view.split.vertical.botright(0.45),
          should_map_plug = false,
          execute_repl_with_workspace = true,
          scratch_repl = true,
          repl_definition = {
            python = { command = { "jupyter", "console" }, format = require("iron.fts.common").bracketed_paste },
            sh = { command = { "bash" }, format = require("iron.fts.common").bracketed_paste },
          },
        },
        keymaps = { send_motion = "str", send_line = "stR", visual_send = "str", send_file = "stf" },
      })
    end,
  },
}

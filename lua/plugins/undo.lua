-- lvim.keys.normal_mode["Z"] = { "<cmd>UndotreeToggle<cr>", desc = "Toggle undo tree" }
vim.g.undotree_DiffAutoOpen = 1
vim.g.undotree_SetFocusWhenToggle = 1
vim.g.undotree_ShortIndicators = 1
vim.g.undotree_WindowLayout = 2
vim.g.undotree_DiffpanelHeight = 8
vim.g.undotree_SplitWidth = 24

function _G.Undotree_CustomMap()
  local opts = { buffer = true, silent = true }
  vim.keymap.set("n", "i", "<plug>UndotreeNextState", opts)
  vim.keymap.set("n", "k", "<plug>UndotreePreviousState", opts)
  vim.keymap.set("n", "I", "5<plug>UndotreeNextState", opts)
  vim.keymap.set("n", "K", "5<plug>UndotreePreviousState", opts)
end

vim.cmd([[
  function! g:Undotree_CustomMap() abort
    call v:lua.Undotree_CustomMap()
  endfunction
]])


return {
  {
    "mbbill/undotree",
    event = "User FileOpened",
  },
  {
    "kevinhwang91/nvim-fundo",
    event = "User FileOpened",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    build = function() require("fundo").install() end,
    lazy = false,
    init = function() vim.opt.undofile = true end,
    config = function()
      require("fundo").setup()
    end
  },
  {
    "debugloop/telescope-undo.nvim",
    event = "VeryLazy",
    dependencies = { -- note how they're inverted to above example
      {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
    keys = {
      { -- lazy style key map
        "<leader>sz",
        "<cmd>Telescope undo<cr>",
        desc = "undo history",
      },
    },
    opts = {
      -- don't use `defaults = { }` here, do this in the main telescope spec
      extensions = {
        undo = {
          -- telescope-undo.nvim config, see below
        },
        -- no other extensions here, they can have their own spec too
      },
    },
    config = function(_, opts)
      -- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
      -- configs for us. We won't use data, as everything is in it's own namespace (telescope
      -- defaults, as well as each extension).
      require("telescope").setup(opts)

      local origin_get_previewer = require("telescope-undo.previewer").get_previewer
      local previewers = require("telescope.previewers")
      local is_wsl = (function()
        local output = vim.fn.systemlist("uname -r")
        return not not string.find(output[1] or "", "WSL")
      end)()
      local has_powershell = vim.fn.executable("powershell") == 1
      local has_bash = vim.fn.executable("bash") == 1
      require("telescope-undo.previewer").get_previewer = function(o)
        o = o or {}
        if o.use_custom_command == nil and not (o.use_delta and not is_wsl and (has_powershell or has_bash) and vim.fn.executable("delta") == 1) then
          return previewers.new_buffer_previewer({
            -- this is not the prettiest preview...
            define_preview = function(self, entry, _)
              vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, true, vim.split(entry.value.diff, "\n"))
              require("telescope.previewers.utils").highlighter(
                self.state.bufnr,
                "diff",
                { preview = { treesitter = { enable = true } } }
              )
            end,
          })
        else
          return origin_get_previewer(o)
        end
      end
      require("telescope").load_extension("undo")
    end,
  },
}

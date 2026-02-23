vim.api.nvim_create_autocmd("User", {
  pattern = "FileOpened",
  callback = function()
    local null_ls = require("null-ls")
    local formatters = require("lvim.lsp.null-ls.formatters")
    local code_actions = require("lvim.lsp.null-ls.code_actions")

    local tailwind_support_filetypes = {
      "html",
      "htmldjango",
      "php",
      "css",
      "javascriptreact",
      "typescriptreact",
    }

    local tailwind_code_actions = {
      {
        name = "tailwindcss_sort",
        title = "Sort Tailwind CSS classes",
        action = function() vim.api.nvim_command("TailwindSort") end,
      },
      {
        name = "tailwind_conceal_toggle",
        title = "Toggle Tailwind CSS Classes Folding",
        action = function() vim.api.nvim_command("TailwindConcealToggle") end,
      },
    }

    for _, action in ipairs(tailwind_code_actions) do
      null_ls.register({
        name = action.name,
        method = null_ls.methods.CODE_ACTION,
        filetypes = tailwind_support_filetypes,
        generator = {
          fn = function(params)
            return {
              {
                title = action.title,
                action = action.action,
              },
            }
          end,
        },
      })
    end

    null_ls.register({
      name = "ruff_format",
      method = null_ls.methods.CODE_ACTION,
      filetypes = { "python" },
      generator = {
        fn = function(params)
          return {
            {
              title = "Ruff: Format",
              action = Nvim.null_ls.create_cli_format_action({
                name = "ruff_format",
                command = "ruff",
                args = { "format", "$FILENAME" },
              }),
            },
          }
        end,
      },
    })

    formatters.setup({
      {
        command = "prettier",
        filetypes = {
          "css",
          "javascript",
          "typescript",
          "typescriptreact",
        },
      },
    })

    code_actions.setup({
      { name = "gitsigns" },
    })
  end,
})

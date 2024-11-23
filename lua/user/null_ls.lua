local null_ls = require("null-ls")

-- define support filetypes for TailwindCSS
local tailwind_support_filetypes = {
  "html",
  "htmldjango",
  "php",
  "css",
  "javascriptreact",
  "typescriptreact",
}
-- define code action for TailwindSort
local tailwind_code_actions = {
  {
    name = "tailwindcss_sort",
    title = "Sort Tailwind CSS classes",
    action = function()
      vim.api.nvim_command("TailwindSort")
    end,
  },
  {
    name = "tailwind_conceal_toggle",
    title = "Toggle Tailwind CSS Classes Folding",
    action = function()
      vim.api.nvim_command("TailwindConcealToggle")
    end,
  },
}
-- Use a for loop to register all code actions
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


-- Register Ruff formatter
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

null_ls.setup()

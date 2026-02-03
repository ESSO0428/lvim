local M = {}

function M.setup()
  pcall(function()
    require("chafa").setup({
      render = {
        min_padding = 5,
        show_label = true,
      },
      events = {
        update_on_nvim_resize = true,
      },
    })
  end)
end

return M

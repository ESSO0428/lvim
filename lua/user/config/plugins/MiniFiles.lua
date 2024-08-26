vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    local buf_id = args.data.buf_id

    -- Use the function to open the file in the picked window
    local open_in_window_picker = function()
      -- Get the current file system entry under the cursor
      local fs_entry = MiniFiles.get_fs_entry()

      -- Check if the cursor is on a file
      if fs_entry ~= nil and fs_entry.fs_type == "file" then
        -- Select a window and set it as the target
        local picked_window_id = require("window-picker").pick_window()
        -- If no window was picked, exit
        if not picked_window_id then return end
        MiniFiles.set_target_window(picked_window_id)
      end

      -- Continue opening the file in the picked window
      MiniFiles.go_in({
        close_on_file = true,
      })
    end

    -- Bind the function to the "l" key in normal mode for the current buffer
    vim.keymap.set("n", "l", open_in_window_picker, { buffer = buf_id, desc = "Open in target window" })
  end,
})

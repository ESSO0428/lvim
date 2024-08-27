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
        close_on_file = false,
      })
    end
    local open_in_window_picker_split = function(split_cmd)
      -- first, pick a window using window-picker
      local picked_window_id = require("window-picker").pick_window()
      if not picked_window_id then return end

      -- Set the picked window as the target window
      MiniFiles.set_target_window(picked_window_id)

      -- Execute the split operation in the target window
      vim.api.nvim_win_call(picked_window_id, function()
        vim.cmd(split_cmd .. ' split')
        local new_target_window = vim.api.nvim_get_current_win()
        -- Set the new target window
        MiniFiles.set_target_window(new_target_window)
      end)

      -- Continue opening the file in the picked window
      MiniFiles.go_in({
        close_on_file = false,
      })
    end
    -- Bind the function to the `l` key in normal mode for the current buffer
    local open_in_vsplit = function()
      open_in_window_picker_split("vsplit")
    end

    -- Bind the function to the `l` key in normal mode for the current buffer
    local open_in_hsplit = function()
      open_in_window_picker_split("split")
    end

    -- Bind the function to the `l` key in normal mode for the current buffer
    vim.keymap.set("n", "l", open_in_window_picker, { buffer = buf_id, desc = "Open in target window" })
    -- Bind `<a-l>` to open with vsplit in target window
    vim.keymap.set("n", "<a-l>", open_in_vsplit, { buffer = buf_id, desc = "Open with vertical split" })
    -- Bind "<a-k>" to open with split in target window
    vim.keymap.set("n", "<a-k>", open_in_hsplit, { buffer = buf_id, desc = "Open with horizontal split" })
  end,
})

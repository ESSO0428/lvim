-- vim.g.interestingWordsGUIColors       = { '#aeee00', '#ff0000', '#0000ff', '#b88823', '#ffa724', '#ff2c4b' }
vim.g.interestingWordsGUIColors       = { '#aeee00', '#fa3e2d', '#2d93fa', '#b970e0', '#ffa724', '#fc7cc5' }
vim.g.interestingWordsDefaultMappings = 0
lvim.keys.normal_mode['<leader>m']    = "<cmd>call InterestingWords('n')<cr>"
lvim.keys.visual_mode['<leader>m']    = ":call InterestingWords('v')<cr>"
lvim.keys.normal_mode['<leader>M']    = "<cmd>call UncolorAllWords()<cr>"
lvim.keys.normal_mode['n']            = "<cmd>call WordNavigation(1)<cr>"
lvim.keys.normal_mode['N']            = "<cmd>call WordNavigation(0)<cr>"

local ns_previewer                    = vim.api.nvim_create_namespace "telescope.previewers"
local jump_to_line                    = function(self, bufnr, lnum)
  pcall(vim.api.nvim_buf_clear_namespace, bufnr, ns_previewer, 0, -1)
  if lnum and lnum > 0 then
    pcall(vim.api.nvim_buf_add_highlight, bufnr, ns_previewer, "TelescopePreviewLine", lnum - 1, 0, -1)
    pcall(vim.api.nvim_win_set_cursor, self.state.winid, { lnum, 0 })
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd "norm! zz"
    end)
  end
end
-- Function to search for highlighted words using Telescope
function telescope_interestingwords_selected(use_stored_words)
  local highlighted_words = {}

  -- If we're asked to use stored words and they exist, use them
  if use_stored_words and _G.stored_highlighted_words and #_G.stored_highlighted_words > 0 then
    highlighted_words = _G.stored_highlighted_words
  else
    -- Get highlighted words by examining active matches directly with Lua
    local matches = vim.fn.getmatches()
    for _, match in ipairs(matches) do
      local group_name = match.group

      -- Check if the match belongs to an InterestingWord highlight group
      if string.match(group_name, "^InterestingWord%d+$") then
        local pattern = match.pattern

        -- Extract the actual word from the pattern
        -- Handle pattern formats like '\V\<word\>' or '\V\zsword\ze'
        local word = pattern

        -- Simplify the pattern extraction
        word = string.gsub(word, [[\[VcC]\V\<(.*)\>]], "%1")
        word = string.gsub(word, [[\[VcC]\V\zs(.*)\ze]], "%1")

        table.insert(highlighted_words, word)
      end
    end

    -- If no words are highlighted, show an error message
    if #highlighted_words == 0 then
      vim.notify("No highlighted words found", vim.log.levels.WARN)
      return
    end
  end

  -- Show a Telescope menu to select from highlighted words
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  -- Store the list of highlighted words globally so we can reuse it
  _G.stored_highlighted_words = highlighted_words

  -- Create a custom previewer that starts from current cursor position
  local bufnr = vim.api.nvim_get_current_buf()
  -- Get current buffer lines
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  -- Get current cursor position (0-indexed)
  local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1

  -- Function to get a random color from interestingWordsGUIColors for highlighting
  local function get_interesting_word_color(word)
    local colors = vim.g.interestingWordsGUIColors or
        { '#aeee00', '#fa3e2d', '#2d93fa', '#b970e0', '#ffa724', '#fc7cc5' }
    -- Use a hash of the word to select a consistent color for the same word
    local color_index = 1
    for i, highlighted_word in ipairs(highlighted_words) do
      if highlighted_word == word then
        color_index = i
        break
      end
    end
    -- Ensure the index is within bounds
    color_index = ((color_index - 1) % #colors) + 1

    return colors[color_index]
  end

  -- Create a map to store color assignments for each term
  local term_colors = {}

  -- Pre-compute all term colors
  for _, term in ipairs(highlighted_words) do
    term_colors[term] = get_interesting_word_color(term)
  end

  local custom_previewer = require("telescope.previewers").new_buffer_previewer({
    define_preview = function(self, entry, status)
      if not self.state or not self.state.bufnr then
        return
      end

      local search_term = entry.value

      -- Find first occurrence of the keyword from cursor position to end
      local found_index = nil
      for i = current_line, #lines - 1 do
        if lines[i]:match(search_term) then
          found_index = i
          break
        end
      end

      -- If not found after cursor, search from beginning
      if not found_index then
        for i = 1, current_line - 1 do
          if lines[i]:match(search_term) then
            found_index = i
            break
          end
        end
      end

      -- Get file content for preview buffer
      require("telescope.previewers.utils").set_preview_message(self.state.bufnr, status.preview_win,
        "Loading preview...")

      -- Fill preview buffer with current buffer content
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

      -- Set filetype for syntax highlighting
      local ft = vim.bo[bufnr].filetype
      if ft ~= "" then
        vim.bo[self.state.bufnr].filetype = ft
      end

      -- Create a buffer-local variable to track if highlights are applied
      if not self.state.highlights_applied then
        self.state.highlights_applied = false
      end

      -- Position preview at found line or at current cursor line if not found
      vim.defer_fn(function()
        if not self.state or not self.state.bufnr or not vim.api.nvim_buf_is_valid(self.state.bufnr) then
          return
        end

        pcall(function()
          vim.api.nvim_buf_call(self.state.bufnr, function()
            local line_to_show = found_index and (found_index + 1) or (current_line + 1)
            jump_to_line(self, self.state.bufnr, line_to_show - 1)

            -- Only apply highlights once per buffer
            if not self.state.highlights_applied then
              -- Highlight all interesting words in the preview
              for term, color in pairs(term_colors) do
                -- Create a unique highlight group name for this term
                local hl_group = "TelescopeInterestingWord_" .. string.gsub(term, "[^%w]", "_")

                -- Define the highlight group with the pre-computed color
                vim.cmd(string.format("highlight %s guifg=black guibg=%s", hl_group, color))

                -- Highlight the term with our custom highlight group
                vim.fn.matchadd(hl_group, "\\V" .. term)
              end

              -- Mark highlights as applied
              self.state.highlights_applied = true
            end
          end)
        end)
      end, 10)
    end,
  })

  bufnr = vim.api.nvim_get_current_buf()
  pickers.new({}, {
    prompt_title = "Interestingwords Selected",
    finder = finders.new_table {
      results = highlighted_words,
    },
    sorter = conf.generic_sorter({}),
    previewer = custom_previewer,
    attach_mappings = function(prompt_bufnr, map)
      -- Store occurrences and indices for each word
      local word_occurrences = {}
      local word_indices = {} -- Track the current index for each word
      local current_word = nil
      local current_occurrence_index = 1

      local function find_occurrences(word)
        -- If we already have occurrences for this word, just return them
        if word_occurrences[word] then
          current_word = word
          -- Use saved index or default to 1
          current_occurrence_index = word_indices[word] or 1
          return #word_occurrences[word] > 0
        end

        -- Initialize occurrences for this word
        word_occurrences[word] = {}
        word_indices[word] = 1
        current_word = word
        current_occurrence_index = 1

        -- Use the original buffer for searching, not the telescope buffer
        local original_bufnr = bufnr -- This is set to the original buffer at the start of the function
        local lines = vim.api.nvim_buf_get_lines(original_bufnr, 0, -1, false)

        -- Escape special characters in the word for proper pattern matching
        -- This helps with exact word matches
        local escaped_word = word:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")

        for i, line in ipairs(lines) do
          -- Use Lua pattern matching to find all occurrences in each line
          local start_idx = 1
          while true do
            -- Try to find the word in the line
            local match_start, match_end = line:find(escaped_word, start_idx, true)
            if not match_start then break end

            -- Add this occurrence to our list
            table.insert(word_occurrences[word], {
              lnum = i,
              col = match_start,
              text = line
            })

            -- Move to position after this match to find next occurrence
            start_idx = match_end + 1
          end
        end

        return #word_occurrences[word] > 0
      end

      local function navigate_occurrences(direction)
        local selection = action_state.get_selected_entry()
        if not selection or not selection.value then
          vim.notify("No selection found", vim.log.levels.WARN)
          return
        end

        -- Check if this is a different word than the current one
        local selected_word = selection.value
        if selected_word ~= current_word then
          -- Find occurrences for this word
          if not find_occurrences(selected_word) then
            return
          end
        end

        local occurrences = word_occurrences[selected_word]
        if not occurrences or #occurrences == 0 then
          return
        end

        -- Update index based on direction
        if direction == "next" then
          current_occurrence_index = current_occurrence_index % #occurrences + 1
        elseif direction == "prev" then
          current_occurrence_index = current_occurrence_index - 1
          if current_occurrence_index < 1 then
            current_occurrence_index = #occurrences
          end
        end

        -- Remember the current index for this word
        word_indices[selected_word] = current_occurrence_index

        -- Get the current occurrence
        local occurrence = occurrences[current_occurrence_index]

        -- Update preview to show the current occurrence
        local picker = action_state.get_current_picker(prompt_bufnr)
        if picker and picker.previewer and picker.previewer.state and picker.previewer.state.bufnr then
          -- Jump to the line in the preview window
          jump_to_line(picker.previewer, picker.previewer.state.bufnr, occurrence.lnum)
        end
      end

      -- Map <a-,> and <a-.> or (or < and >) for navigating occurrences
      map("n", "<a-,>", function() navigate_occurrences("prev") end)
      map("n", "<a-.>", function() navigate_occurrences("next") end)
      map("n", "<", function() navigate_occurrences("prev") end)
      map("n", ">", function() navigate_occurrences("next") end)
      map("i", "<a-,>", function() navigate_occurrences("prev") end)
      map("i", "<a-.>", function() navigate_occurrences("next") end)
      map("n", "<Up>", function() actions.move_selection_previous(prompt_bufnr) end)
      map("n", "<Down>", function() actions.move_selection_next(prompt_bufnr) end)
      map("i", "<Up>", function() actions.move_selection_previous(prompt_bufnr) end)
      map("i", "<Down>", function() actions.move_selection_next(prompt_bufnr) end)
      map("n", "<a-m>", function() end)
      map("i", "<a-m>", function() end)

      -- Override the move_selection functions to automatically navigate occurrences
      local orig_move_selection_next = actions.move_selection_next
      actions.move_selection_next = function(prompt_bufnr)
        orig_move_selection_next(prompt_bufnr)
        vim.defer_fn(function()
          navigate_occurrences()
        end, 10)
      end
      local orig_move_selection_prev = actions.move_selection_previous
      actions.move_selection_previous = function(prompt_bufnr)
        orig_move_selection_prev(prompt_bufnr)
        vim.defer_fn(function()
          navigate_occurrences()
        end, 10)
      end


      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()

        -- Ensure we have a valid selection
        if not selection or not selection.value then
          vim.notify("No selection found", vim.log.levels.WARN)
          actions.close(prompt_bufnr)
          return
        end

        -- Check if this is a different word than the current one
        local selected_word = selection.value
        if selected_word ~= current_word then
          -- Find occurrences for this word
          if not find_occurrences(selected_word) then
            vim.notify("No occurrences found for: " .. selected_word, vim.log.levels.WARN)
            actions.close(prompt_bufnr)
            return
          end
        end

        local occurrences = word_occurrences[selected_word]
        if not occurrences or #occurrences == 0 then
          vim.notify("No occurrences found for: " .. selected_word, vim.log.levels.WARN)
          actions.close(prompt_bufnr)
          return
        end

        -- Get the current occurrence
        local occurrence = occurrences[current_occurrence_index]
        actions.close(prompt_bufnr)

        -- Use defer_fn to ensure we jump after the telescope UI is closed
        vim.defer_fn(function()
          -- Jump to the occurrence in the main buffer
          vim.api.nvim_win_set_cursor(0, { occurrence.lnum, occurrence.col - 1 })
          -- Center the view
          vim.cmd("normal! zz")
          -- Give visual feedback
          vim.notify("Jumped to occurrence " .. current_occurrence_index .. " of " .. #occurrences ..
            " for: " .. selected_word, vim.log.levels.INFO)
        end, 10)
      end)
      return true
    end,
  }):find()
end

-- Add keybinding for searching highlighted words
lvim.builtin.which_key.mappings.s.i = { "<cmd>lua telescope_interestingwords_selected(false)<cr>",
  "Search interestingwords" }

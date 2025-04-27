-- vim.g.interestingWordsGUIColors       = { '#aeee00', '#ff0000', '#0000ff', '#b88823', '#ffa724', '#ff2c4b' }
vim.g.interestingWordsGUIColors       = { '#aeee00', '#fa3e2d', '#2d93fa', '#b970e0', '#ffa724', '#fc7cc5' }
vim.g.interestingWordsDefaultMappings = 0
lvim.keys.normal_mode['<leader>m']    = "<cmd>call InterestingWords('n')<cr>"
lvim.keys.visual_mode['<leader>m']    = ":call InterestingWords('v')<cr>"
lvim.keys.normal_mode['<leader>M']    = "<cmd>call UncolorAllWords()<cr>"
lvim.keys.normal_mode['n']            = "<cmd>call WordNavigation(1)<cr>"
lvim.keys.normal_mode['N']            = "<cmd>call WordNavigation(0)<cr>"

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

      -- Position preview at found line or at current cursor line if not found
      vim.defer_fn(function()
        if not self.state or not self.state.bufnr or not vim.api.nvim_buf_is_valid(self.state.bufnr) then
          return
        end

        pcall(function()
          vim.api.nvim_buf_call(self.state.bufnr, function()
            local line_to_show = found_index and (found_index + 1) or (current_line + 1)
            local ns_previewer = vim.api.nvim_create_namespace "telescope.previewers"
            vim.cmd("normal! " .. line_to_show .. "Gzz")

            -- Get a color from interestingWordsGUIColors based on the search term
            local color = get_interesting_word_color(search_term)

            -- Create a unique highlight group name for this term
            local hl_group = "TelescopeInterestingWord_" .. string.gsub(search_term, "[^%w]", "_")

            -- Define the highlight group with the selected color
            vim.cmd(string.format("highlight %s guifg=black guibg=%s", hl_group, color))

            -- Highlight the search term with our custom highlight group
            vim.fn.matchadd(hl_group, "\\V" .. search_term)
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
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        -- Search for the selected word in current buffer only
        local fb = require("telescope.builtin").current_buffer_fuzzy_find({
          -- NOTE: Add `'` prefix for exact match
          default_text = selection.value and "'" .. selection.value or selection.value,
          attach_mappings = function(inner_prompt_bufnr, inner_map)
            -- Add <C-k> mapping to go back to the interesting words picker (insert and normal mode)
            local back_to_picker = function()
              actions.close(inner_prompt_bufnr)
              -- Reopen the interesting words picker with the stored words
              telescope_interestingwords_selected(true)
            end

            -- Map for both insert mode and normal mode
            inner_map("i", "<C-k>", back_to_picker)
            inner_map("n", "<C-k>", back_to_picker)
            return true
          end,
        })
      end)
      return true
    end,
  }):find()
end

-- Add keybinding for searching highlighted words
lvim.builtin.which_key.mappings.s.i = { "<cmd>lua telescope_interestingwords_selected(false)<cr>",
  "Search interestingwords" }

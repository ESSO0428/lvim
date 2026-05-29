return {
  {
    "github/copilot.vim",
    commit = "7097b09",
    event = "InsertEnter", -- 進入 Insert 才啟動 Copilot
  },
  {
    "hrsh7th/cmp-copilot",
    event = "InsertEnter",
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    cmd = { "CopilotChat", "CopilotChatToggle" },
    -- NOTE: If you can't activate the plugin, please check the following:
    -- 1. Check if the $XDG_RUNTIME_DIR directory exists.
    -- 2. Verify the permissions of $XDG_RUNTIME_DIR:
    --    - Use the command `ls -ld $XDG_RUNTIME_DIR` to check its existence and permissions.
    -- 3. If the directory does not exist, create it with: `mkdir -p $XDG_RUNTIME_DIR`.
    -- 4. Set appropriate permissions:
    --    - For example, you can use `chmod 755 $XDG_RUNTIME_DIR`
    --    - Alternatively, use `chmod 777 $XDG_RUNTIME_DIR`
    dependencies = {
      { "github/copilot.vim" },    -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    keys = {
      {
        "<leader>uki",
        function()
          require("user.copilot").quickchat(false)
        end,
        desc = "CopilotChat: quick chat panel",
      },
      {
        "<leader>uki",
        function()
          require("user.copilot").quickchat_visual(false)
        end,
        mode = { "v" },
        desc = "CopilotChat: quick chat panel",
      },
      {
        "<leader>ukw",
        function()
          require("user.copilot").no_context_chat()
        end,
        desc = "CopilotChat: no context chat",
      },
      {
        "<leader>uka",
        function()
          require("user.copilot").quickchat(true)
        end,
        desc = "CopilotChat: quick chat",
      },
      {
        "<leader>uka",
        function()
          require("user.copilot").quickchat_visual(true)
        end,
        mode = { "v" },
        desc = "CopilotChat: quick chat",
      },
      {
        "<leader>ukk",
        function()
          require("user.copilot").prompt_action()
        end,
        desc = "CopilotChat: prompt action",
      },
      {
        "<leader>ukk",
        function()
          require("user.copilot").prompt_action()
        end,
        mode = { "v" },
        desc = "CopilotChat: prompt action",
      },
    },
    config = function()
      require("user.copilot").setup()
    end,
  },
}

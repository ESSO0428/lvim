return {
  -- NOTE: The handling of `concealcursor` in LSP hover markdown rendering
  -- was changed after commit 0022a57. The previous behavior allowed
  -- concealed elements to be visible, but the new version hides them
  -- by default.
  -- If you prefer the old behavior in LSP hover windows, check issue #312
  -- for possible workarounds: [#312](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/312)
  {
    "MeanderingProgrammer/markdown.nvim",
    main = "render-markdown",
    opts = {},
    name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ft = { 'markdown', 'Avante', 'AvanteInput', 'copilot-chat' },
    config = function()
      require("user.config.plugins.MarkdownNvim").setup()
    end
  },
  {
    "ESSO0428/mkdnflow.nvim",
    ft = { "markdown" }, -- 只在 markdown 開啟
    config = function()
      require("user.config.plugins.mkdnflow").setup()
    end
  },
  {
    "ESSO0428/md-headers.nvim",
    ft = { "markdown" }, -- 只在 markdown 開啟
    deprecated = { 'nvim-lua/plenary.nvim' }
  },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft = "markdown",
    config = function()
      vim.g.mkdp_auto_start = 1
    end
  },
  {
    "lukas-reineke/headlines.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    ft = { "markdown", "md", "org", "norg", "rmd" },
    config = function()
      require("user.config.plugins.headline").setup()
    end,
  },
  {
    "nvim-orgmode/orgmode",
    ft = { "org" }, -- 只在 org 檔載入
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter', lazy = true },
    },
    config = function()
      require("user.config.plugins.OrgMode").setup()
    end,
  },
  {
    "akinsho/org-bullets.nvim",
    ft = { "org" },
    config = function()
      require('org-bullets').setup()
    end
  },
  -- NOTE: because orgmode update and org.parser.files depend on orgmode, so I have to disable it
  -- {
  --   "joaomsa/telescope-orgmode.nvim"
  -- },
}

local dap = require('dap')
local LoadLaunchJsonSucess = vim.g.LoadLaunchJsonSucess
local launch_configs = {}
local attach_configs = {}
local example_launch_configs = {}
local example_attach_configs = {}

-- Reference:
--  - https://www.lazyvim.org/extras/lang/typescript
--  - https://stackoverflow.com/questions/78455585/correct-setup-for-debugging-nextjs-app-inside-neovim-with-dap
dap.adapters['chrome'] = {
  type = 'executable',
  command = 'node',
  -- TODO change to your correct path
  args = { vim.fn.stdpath('data') .. '/mason/packages/chrome-debug-adapter/out/src/chromeDebug.js' },
}
dap.adapters['firefox'] = {
  type = 'executable',
  command = 'node',
  -- TODO change to your correct path
  args = { vim.fn.stdpath('data') .. '/mason/packages/firefox-debug-adapter/dist/adapter.bundle.js' },
}
dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "node",
    -- 💀 Make sure to update this path to point to your installation
    args = {
      vim.fn.stdpath('data') .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
      "${port}",
    },
  },
}

dap.adapters["node"] = function(cb, config)
  if config.type == "node" then
    config.type = "pwa-node"
  end
  local nativeAdapter = dap.adapters["pwa-node"]
  if type(nativeAdapter) == "function" then
    nativeAdapter(cb, config)
  else
    cb(nativeAdapter)
  end
end

local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

local vscode = require("dap.ext.vscode")
vscode.type_to_filetypes["node"] = js_filetypes
vscode.type_to_filetypes["pwa-node"] = js_filetypes
vscode.type_to_filetypes["chrome"] = js_filetypes
vscode.type_to_filetypes["firefox"] = js_filetypes

example_attach_configs = {
  {
    -- NOTE: Try below in command line or package.json script
    -- and then run `:lua require('dap').continue()`
    -- command line: NODE_OPTIONS='--inspect=9230' npm run dev
    -- package.json: "dev-debug": "NODE_OPTIONS='--inspect=9230' next dev"
    -- (and run `npm run dev-debug`)
    name = 'Next.js: debug attach server-side (example)',
    type = 'pwa-node',
    request = 'attach',
    port = 9231,
    skipFiles = { '<node_internals>/**', 'node_modules/**' },
    cwd = '${workspaceFolder}',
  },
}
launch_configs = {
  {
    name = "Launch Firefox (custom connect)",
    type = "firefox",
    request = "launch",
    url = function()
      return vim.fn.input("Select url: ", "http://localhost:3000")
    end,
    reAttach = true,
    webRoot = "${workspaceFolder}",
    -- pathMappings = {
    --   {
    --     url = "webpack://_N_E",
    --     path = "${workspaceFolder}"
    --   }
    -- }
  },
  {
    name = 'Next.js: debug client-side (chrome)',
    type = 'chrome',
    request = 'launch',
    url = 'http://localhost:3000',
    webRoot = '${workspaceFolder}',
    sourceMaps = true, -- https://github.com/vercel/next.js/issues/56702#issuecomment-1913443304
    sourceMapPathOverrides = {
      ['webpack://_N_E/*'] = '${webRoot}/*',
    },
  },
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    cwd = "${workspaceFolder}",
  },
}
attach_configs = {
  {
    name = "Attach Firefox (custom connect)",
    type = "firefox",
    request = "attach",
    reAttach = true,
    -- See https://github.com/firefox-devtools/vscode-firefox-debug/issues/306
    url = function()
      return vim.fn.input("Select url: ", "http://localhost:3000")
    end,
    webRoot = "${workspaceFolder}",
  },
  {
    type = "chrome",
    request = "attach",
    name = "Attach Program (pwa-chrome, select port)",
    program = "${file}",
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    port = function()
      return vim.fn.input("Select port: ", 9222)
    end,
    webRoot = "${workspaceFolder}",
  },
  {
    -- NOTE: Try below in command line or package.json script
    -- and then run `:lua require('dap').continue()`
    -- command line: NODE_OPTIONS='--inspect=9230' npm run dev
    -- package.json: "dev-debug": "NODE_OPTIONS='--inspect=9230' next dev"
    -- (and run `npm run dev-debug`)
    name = 'Next.js: debug attach server-side (custom connect)',
    type = 'pwa-node',
    request = 'attach',
    port = function()
      local port = tonumber(vim.fn.input('Port [9231]: ')) or 9231
      return port
    end,
    skipFiles = { '<node_internals>/**', 'node_modules/**' },
    cwd = '${workspaceFolder}',
  },
  {
    type = "pwa-node",
    request = "attach",
    name = "Attach to Process",
    processId = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
  },
}

for _, language in ipairs(js_filetypes) do
  local target_lang = language

  if LoadLaunchJsonSucess == true then
    require('dap.ext.vscode').load_launchjs()
  else
    Nvim.DAP.insert_dap_configs(target_lang, example_launch_configs)
    Nvim.DAP.insert_dap_configs(target_lang, example_attach_configs)
  end
  Nvim.DAP.insert_dap_configs(target_lang, launch_configs)
  Nvim.DAP.insert_dap_configs(target_lang, attach_configs)
end

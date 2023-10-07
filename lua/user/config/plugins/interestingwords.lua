vim.g.interestingWordsGUIColors       = { '#aeee00', '#ff0000', '#0000ff', '#b88823', '#ffa724', '#ff2c4b' }
vim.g.interestingWordsGUIColors       = { '#aeee00', '#fa3e2d', '#2d93fa', '#b970e0', '#ffa724', '#fc7cc5' }
vim.g.interestingWordsDefaultMappings = 0
lvim.keys.normal_mode['<leader>m']    = ":call InterestingWords('n')<cr>"
lvim.keys.visual_mode['<leader>m']    = ":call InterestingWords('v')<cr>"
lvim.keys.normal_mode['<leader>M']    = ":call UncolorAllWords()<cr>"
lvim.keys.normal_mode['n']            = ":call WordNavigation(1)<cr>"
lvim.keys.normal_mode['N']            = ":call WordNavigation(0)<cr>"

local ft = vim.bo.filetype
local marker = Nvim.builtin.FtFoldMarker[ft]
if marker and type(marker) == "string" and marker:find(",") then
  vim.opt_local.foldmarker = marker
end

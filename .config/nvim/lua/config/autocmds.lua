-- This file is automatically loaded by lazyvim.config.init.

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end
local ibus_prev_engine = nil

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "txt" },
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- Define augroup to group the auto commands
local augroup = vim.api.nvim_create_augroup("AutoSaveGroup", { clear = true })

-- Autosave function
local function autosave(buf)
  -- Check if the buffer is valid before trying to save
  if vim.api.nvim_buf_is_valid(buf) then
    if vim.bo[buf].modified and vim.api.nvim_buf_get_name(buf) ~= "" and vim.bo[buf].buftype == "" then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent! write")
        vim.notify("Đã lưu: " .. vim.api.nvim_buf_get_name(buf), vim.log.levels.INFO, { title = "Auto-Save" })
      end)
    end
  end
end

-- Auto-save on InsertLeave event
vim.api.nvim_create_autocmd("InsertLeave", {
  group = augroup,
  callback = function(event)
    vim.defer_fn(function()
      -- Ensure the buffer is valid before calling autosave
      if vim.api.nvim_buf_is_valid(event.buf) then
        autosave(event.buf)
      end
    end, 2000)
  end,
})

-- Auto-save on BufLeave, FocusLost, and VimLeavePre events
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "VimLeavePre" }, {
  group = augroup,
  callback = function(event)
    vim.schedule(function()
      -- Ensure the buffer is valid before calling autosave
      if vim.api.nvim_buf_is_valid(event.buf) then
        autosave(event.buf)
      end
    end)
  end,
})

local supported_filetypes = {
  markdown = true,
  text = true,
  norg = true,
}

local function IBusOff()
  vim.cmd("silent !ibus engine BambooUs")
end

local function IBusOn()
  if supported_filetypes[vim.bo.filetype] then
    vim.cmd("silent !ibus engine Bamboo")
  end
end

local ibus_group = vim.api.nvim_create_augroup("IbusHandler", { clear = true })

vim.api.nvim_create_autocmd("CmdlineEnter", {
  callback = function()
    local t = vim.fn.getcmdtype()
    if t == "/" or t == "?" then
      IBusOn()
    end
  end,
  group = ibus_group,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
  pattern = "[/?]",
  callback = function()
    IBusOff()
  end,
  group = ibus_group,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    IBusOn()
  end,
  group = ibus_group,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    IBusOff()
  end,
  group = ibus_group,
})

-- Tắt IBus khi khởi động
IBusOff()

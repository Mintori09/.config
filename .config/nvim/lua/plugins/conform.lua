return {
  {
    "stevearc/conform.nvim",
    opts = function()
      ---@type conform.setupOpts
      local opts = {
        default_format_opts = {
          timeout_ms = 3000,
          async = false,
          quiet = false,
          lsp_format = "fallback",
        },
        formatters_by_ft = {
          lua = { "stylua" },
          fish = { "fish_indent" },
          sh = { "shfmt" },
          json = { "prettier" },
          rust = { "rustfmt" },
        },
        formatters = {
          injected = { options = { ignore_errors = true } },
          shfmt = { prepend_args = { "-i", "2", "-ci" } },
        },
      }
      return opts
    end,
  },
}

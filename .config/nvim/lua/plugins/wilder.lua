return {
  "gelguy/wilder.nvim",
  event = "CmdlineEnter",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" }, -- Optional: Adds icons
  },
  config = function()
    local wilder = require("wilder")

    -- Enable wilder for command line
    wilder.setup({ modes = { ":", "/", "?" } })

    -- Use fuzzy search (default Lua filter, no extra dependencies)
    wilder.set_option("pipeline", {
      wilder.branch(
        wilder.cmdline_pipeline({
          fuzzy = 1, -- Enable fuzzy matching
        }),
        wilder.search_pipeline()
      ),
    })

    -- Set popup UI similar to cmp
    wilder.set_option(
      "renderer",
      wilder.popupmenu_renderer(wilder.popupmenu_border_theme({
        border = "rounded",
        highlighter = wilder.basic_highlighter(), -- Basic highlighter (no fzy required)
        left = { " ", wilder.popupmenu_devicons() }, -- Show file icons
        right = { " ", wilder.popupmenu_scrollbar() }, -- Scrollbar
      }))
    )
  end,
}

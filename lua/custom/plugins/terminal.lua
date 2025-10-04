return {
  {
    "dummy/terminal",
    dir = vim.fn.stdpath("config"),
    config = function()
      local set = vim.opt_local

      -- Set local settings for terminal buffers
      vim.api.nvim_create_autocmd("TermOpen", {
        group = vim.api.nvim_create_augroup("custom-term-open", {}),
        callback = function()
          set.number = false
          set.relativenumber = false
          set.scrolloff = 0

          vim.bo.filetype = "terminal"
        end,
      })

      -- Easily hit escape in terminal mode.
      vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

      -- Open a terminal at the bottom of the screen with a fixed height.
      vim.keymap.set("n", ",st", function()
        vim.cmd("botright 12split | terminal")
      end)
    end,
  },
}

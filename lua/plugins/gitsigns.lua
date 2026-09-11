return {
  "lewis6991/gitsigns.nvim",
  config = function()
    -- for fixing the diagnose signs mixing issue
    vim.opt.signcolumn = "yes:2"

    vim.diagnostic.config({
      signs = {
        priority = 10,
      },
    })
    -- /

    require("gitsigns").setup({
      -- for fixing the diagnose signs mixing issue
      sign_priority = 20,
      -- /
    })
  end,
}

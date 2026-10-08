return {
   "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
	variant = "default",
        transparent = true,
        italic_comments = true,
    },
    config = function(_, opts)
        require("cyberdream").setup(opts)
    end,
}

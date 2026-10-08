return {
	"rose-pine/neovim",
	name = "rose-pine",
	opts = {
		variant = "moon", -- auto, main, moon, or dawn
		dim_inactive_windows = true,
		styles = {
			bold = true,
        		italic = true,
        		transparency = true,
    		},

	},
	config = function(_, opts)
		require("rose-pine").setup(opts)
	end
}

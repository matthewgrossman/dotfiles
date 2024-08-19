return {
	"tpope/vim-fugitive",
	dependencies = {
		{ "tpope/vim-rhubarb" },
	},
	config = function()
		vim.keymap.set("n", "<leader>gg", ":tab Git<cr>")
		vim.keymap.set("n", "<leader>gdd", ":Gdiffsplit<cr>")
		vim.keymap.set("n", "<leader>gb", ":Git blame<cr>")
		vim.keymap.set("n", "<leader>ga", ":Gwrite<cr>")
		vim.keymap.set("n", "<leader>gp", ":Git push<cr>")
		vim.keymap.set("n", "<leader>gh", "V:GBrowse<cr>")
		vim.keymap.set("v", "<leader>gh", ":GBrowse<cr>")
		vim.keymap.set("v", "<leader>gr", ":Git pr<cr>")
	end,
}

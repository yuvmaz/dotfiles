-- Toggle, create, and navigate comments with NERDCommenter-style keymaps
return {
	"numToStr/comment.nvim",
	config = function()
		require("Comment").setup()

		local map = vim.keymap.set
		local opts = { noremap = true, silent = true }

		-- ============================================================================
		-- COMMENTING MOTIONS
		-- ============================================================================

		-- <leader>cc: Comment out line/selection (works in normal and visual modes)
		map("n", "<leader>cc", function()
			require("Comment.api").toggle.linewise.current()
		end, { desc = "Comment line", noremap = true, silent = true })

		map("v", "<leader>cc", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
			{ desc = "Comment selection", noremap = true, silent = true })

		-- <leader>c<space>: Toggle comment on line/selection (smart toggle)
		map("n", "<leader>c<space>", function()
			require("Comment.api").toggle.linewise.current()
		end, { desc = "Toggle comment line", noremap = true, silent = true })

		map("v", "<leader>c<space>", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
			{ desc = "Toggle comment selection", noremap = true, silent = true })

		-- <leader>cm: Block comment (create multi-line comment)
		map("n", "<leader>cm", function()
			require("Comment.api").toggle.blockwise.current()
		end, { desc = "Block comment line", noremap = true, silent = true })

		map("v", "<leader>cm", "<ESC><cmd>lua require('Comment.api').toggle.blockwise(vim.fn.visualmode())<CR>",
			{ desc = "Block comment selection", noremap = true, silent = true })

		-- ============================================================================
		-- COMMENTING WITH MOTIONS
		-- ============================================================================

		-- <leader>c{motion}: Comment lines with a motion (e.g., <leader>c5j comments 5 lines down)
		map("n", "<leader>c", "<cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
			{ desc = "Comment motion", noremap = false, silent = true })

		-- ============================================================================
		-- UNCOMMENT OPERATIONS
		-- ============================================================================

		-- <leader>cu: Uncomment line/selection
		map("n", "<leader>cu", function()
			require("Comment.api").toggle.linewise.current()
		end, { desc = "Uncomment line", noremap = true, silent = true })

		map("v", "<leader>cu", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
			{ desc = "Uncomment selection", noremap = true, silent = true })

		-- <leader>cy: Yank and comment line/selection
		map("n", "<leader>cy", function()
			require("Comment.api").call("linewise", "toggle")
		end, { desc = "Yank and comment line", noremap = true, silent = true })

		map("v", "<leader>cy", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
			{ desc = "Yank and comment selection", noremap = true, silent = true })
	end,
}

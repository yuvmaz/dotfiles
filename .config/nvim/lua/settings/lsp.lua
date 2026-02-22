vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local opts = { buffer = args.buf, silent = true }

		-- Enable inlay hints for all LSP clients
		vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })

		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client.name == "basedpyright" then
			client.server_capabilities.documentFormattingProvider = false
		end

		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
		vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)

		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)

		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" } },
				apply = true,
			})
		end, opts)
	end,
})

vim.o.updatetime = 250 -- faster CursorHold trigger (default is 4000ms)

vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, {
			focusable = false,
			close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
			border = "rounded",
			source = "always",
			prefix = "",
			scope = "cursor",
		})
	end,
})

vim.lsp.config("ruff", {
	cmd = { "ruff", "server" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
	settings = {
		organizeImports = true,
		format = {
			enable = true,
		},
	},
})



vim.lsp.config("basedpyright", {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
	settings = {
		basedpyright = {
			analysis = {
				inlayHints = {
					variableTypes = true,
					functionReturnTypes = true,
					callArgumentNames = true,
					genericTypes = true,
				},
			},
		},
	},
})

vim.lsp.config("rust-analyzer", {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", "Cargo.lock", "rust-project.json" },
	settings = {
		["rust-analyzer"] = {
			inlayHints = {
				bindingModeHints = { enable = true },
				chainingHints = { enable = true },
				closingBraceHints = { enable = true, minLines = 25 },
				closureReturnTypeHints = { enable = "with_block" },
				discriminantHints = { enable = "fieldless" },
				implicitDrops = { enable = true },
				lifetimeElisionHints = { enable = "always" },
				parameterHints = { enable = true },
				rangeHints = { enable = true },
				typeHints = { enable = true, hideClosureInitialization = false },
				tupleShuffle = { enable = true },
				reborrowHints = { enable = "mutable" },
				smallerHint = { enable = true },
				expressionAdjustmentHints = { enable = "always" },
				renderColons = true,
				maxLength = nil,
				hideNamedConstructorHints = false,
				closingParenthesisSuggestion = false,
				expressionAdjustmentHintsOnly = false,
				hideCallParentheses = false,
				rangesToHighlight = {
					enable = false,
					style = "block",
				},
			},
		},
	},
})

vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { "luarc.json", "luarc.jsonc", "emmyrc.json", ".luacheckrc", "stylua.toml", ".stylua.toml", "selene.toml", "selene.yaml" },
	settings = {
		Lua = {
			hint = {
				enable = true,
				setType = true,
				paramType = true,
				paramName = "All",
				semicolon = "Ignore",
				arrayIndex = "Auto",
			},
		},
	},
})




vim.lsp.enable("lua_ls")
vim.lsp.enable("basedpyright")
vim.lsp.enable("ruff")
vim.lsp.enable("rust-analyzer")

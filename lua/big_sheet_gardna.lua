-- Forked to extend from: https://github.com/mei28/BigSheetGardna.nvim
--
-- BigSheetGardna: Detects large files and disables specific features in Neovim
local BigSheetGardna = {}

-- Default configuration for the plugin
---@class BigSheetGardna.Config
local config = {
	notify = true, -- Whether to show a notification when a big file is detected
	size_threshold = 1.5 * 1024 * 1024, -- File size threshold (default: 1.5MB)

	-- Function to disable features when a big file is detected
	---@param ctx {buf: number, ft: string} The buffer ID and filetype of the file
	setup = function(ctx)
		vim.b.minianimate_disable = true
		vim.schedule(function()
			vim.bo[ctx.buf].syntax = ctx.ft
		end)

		-- Disable Tree-sitter modules
		vim.cmd("TSBufDisable autotag")
		vim.cmd("TSBufDisable highlight")
		vim.cmd("TSBufDisable incremental_selection")
		vim.cmd("TSBufDisable indent")

		-- Disable native Vim syntax highlighting
		vim.bo[ctx.buf].syntax = "disabled"

		-- Disable ultimate-autopair
		local ok, ua = pcall(require, "ultimate-autopair")
		if ok then
			ua.disable()
		end

		-- Disable raibow-delimiters
		local ok, rbd = pcall(require, "rainbow-delimiters")
		if ok then
			rbd.disable()
		end
	end,
}

--- Initializes BigSheetGardna with user configuration
---@param user_config table|nil A table containing user-defined options to override defaults
function BigSheetGardna.setup(user_config)
	-- Merge user-provided configuration with default settings
	if user_config then
		config = vim.tbl_extend("force", config, user_config)
	end

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("BigFile", { clear = true }),
		pattern = "bigfile",
		callback = function(ev)
			local clients = vim.lsp.get_active_clients({ bufnr = ev.buf })
			for _, client in ipairs(clients) do
				vim.lsp.buf_detach_client(ev.buf, client.id)
			end
		end,
	})

	-- Detect big files based on file size threshold and set filetype as "bigfile"
	vim.filetype.add({
		pattern = {
			[".*"] = {
				--- Function to determine if a file is a "bigfile" based on size
				---@param path string The file path
				---@param buf number The buffer ID
				---@return string|nil Returns "bigfile" if the file exceeds the size threshold; otherwise, returns nil
				function(path, buf)
					if vim.bo[buf] and vim.bo[buf].filetype ~= "bigfile" and path then
						local file_size = vim.fn.getfsize(path)
						if file_size > config.size_threshold then
							return "bigfile"
						end
					end
					return nil
				end,
			},
		},
	})

	-- Create an autocmd to handle files detected as "bigfile"
	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = vim.api.nvim_create_augroup("BigSheetGardna", { clear = true }),
		pattern = "bigfile",
		--- Callback for handling "bigfile" when opened
		---@param ev {buf: number} The autocmd event, including the buffer ID
		callback = function(ev)
			-- Show a notification if enabled in configuration
			if config.notify then
				local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ev.buf), ":p:~:.")
				vim.notify(
					(
						"Big file detected: %s. The following Neovim features have been disabled:\n"
						.. "- Syntax highlighting\n"
						.. "- Tree-sitter modules\n"
						.. "- Native Vim syntax highlighting\n"
						.. "- RainbowDelimiters"
					):format(path),
					vim.log.levels.WARN,
					{ title = "BigSheetGardna" }
				)
			end
			-- Apply the specified setup function to disable certain features
			vim.api.nvim_buf_call(ev.buf, function()
				config.setup({
					buf = ev.buf,
					ft = vim.filetype.match({ buf = ev.buf }) or "",
				})
			end)
		end,
	})
end

return BigSheetGardna

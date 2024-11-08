-- BigSheetGardna: Detects large files and disables specific features in Neovim
local BigSheetGardna = {}

-- Default configuration for the plugin
---@class BigSheetGardna.Config
local config = {
  notify = true,                      -- Whether to show a notification when a big file is detected
  size_threshold = 1.5 * 1024 * 1024, -- File size threshold (default: 1.5MB)

  -- Function to disable features when a big file is detected
  ---@param ctx {buf: number, ft: string} The buffer ID and filetype of the file
  setup = function(ctx)
    vim.b.minianimate_disable = true
    vim.schedule(function()
      vim.bo[ctx.buf].syntax = ctx.ft
    end)
  end,
}

--- Initializes BigSheetGardna with user configuration
---@param user_config table|nil A table containing user-defined options to override defaults
function BigSheetGardna.setup(user_config)
  -- Merge user-provided configuration with default settings
  if user_config then
    config = vim.tbl_extend("force", config, user_config)
  end

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
              -- Ask the user if they want to open the large file
              local answer = vim.fn.confirm(
                ("The file is large (%.2f MB). Do you want to open it?"):format(file_size / (1024 * 1024)),
                "&Yes\n&No", 2
              )
              if answer == 1 then
                return "bigfile"
              else
                -- Exit Neovim if the user selects "No"
                vim.schedule(function()
                  vim.cmd("qa!") -- Force quit Neovim
                end)
                return nil
              end
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
        vim.notify({
          ("Big file detected `%s`."):format(path),
          "Some Neovim features have been **disabled**.",
        }, vim.log.levels.WARN, { title = "BigSheetGardna" })
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


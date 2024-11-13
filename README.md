# 🛡️BigSheetGardna 

**BigSheetGardna** is your Neovim companion, built to *safeguard* your editor when working with **massive files**! Inspired by the idea of a stalwart guardian, BigSheetGardna detects large files on the fly, automatically disabling certain resource-intensive features to keep Neovim *snappy* and *responsive*. 

With BigSheetGardna in action, you’ll avoid the typical slowdowns associated with big files, all while staying informed about which features have been gracefully put on standby. 🚀

## ✨ Features

- **Automatic Big File Detection**: Seamlessly detects files exceeding a custom-defined size limit.
- **Feature Disabling**: Optimizes performance by selectively disabling features (like syntax highlighting) for large files.
- **Notification Alerts**: Sends a friendly notification to inform you when adjustments have been made.

## 🚀 Getting Started

1. **Install** BigSheetGardna by adding it to your Neovim configuration.
2. **Set up your preferences** with flexible options like notification settings and size thresholds.
3. Enjoy *smooth performance* when working with large files!

## 🛠️ Installation

Add BigSheetGardna to your Neovim setup. Here’s an example for **lazy.nvim**:

```lua
{
  "mei28/big_sheet_gardna",
  event = {'BufNewFile', 'BufRead'}, -- if lazy load
  config = function()
    require("big_sheet_gardna").setup({
      notify = true,             -- Show notification for large files
      size_threshold = 1.5 * 1024 * 1024, -- Set size threshold (default: 1.5MB)
    })
  end,
}
```
Once installed, BigSheetGardna will automatically work its magic every time you open a large file!

## ⚙️ Configuration Options
BigSheetGardna is designed to be flexible and adaptable to your needs. Here’s what you can customize:

| Option          | Type      | Default                   | Description                                                    |
|-----------------|-----------|---------------------------|----------------------------------------------------------------|
| `notify`        | `boolean` | `true`                    | Show a notification when a large file is detected.             |
| `size_threshold`| `number`  | `1.5 * 1024 * 1024` (1.5MB)| The file size (in bytes) above which a file is considered "big". |
| `setup`         | `function`| `disable syntax highlighting` | Define specific functions to disable features when a large file is detected. |

Example configuration to customize the behavior:

```lua
require("big_sheet_gardna").setup({
        notify = true, -- Enable notifications
        size_threshold = 2 * 1024 * 1024, -- Set threshold to 2MB
        setup = function(ctx)
            vim.b.minianimate_disable = true
            vim.schedule(function()
                    vim.bo[ctx.buf].syntax = ""
                    end)
        end,
        })
```

## 🌈 How It Works
1. File Detection: Every time you open a file, BigSheetGardna checks its size.
1. Threshold Check: If the file size exceeds size_threshold, the file type is flagged as bigfile.
1. Feature Adjustment: Any features you specify in the setup function (like syntax highlighting) are automatically disabled.
1. Friendly Notification: If notifications are enabled, BigSheetGardna will let you know it’s on the job!

## 🌍 Contributing
BigSheetGardna welcomes contributions! Whether you find a bug, want to suggest an improvement, or simply share feedback, all kinds of help are appreciated. Feel free to submit issues or pull requests on the GitHub repository.

## 📜 License
BigSheetGardna is open-source and licensed under the MIT License.

## 🎩 Credits
BigSheetGardna was inspired by the legendary Big Shield Gardna, guarding your Neovim like a true sentinel against the lag of large files. 😄

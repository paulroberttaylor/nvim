vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "http://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        {
            import = "plugins"
        }
    },
})

local builtin = require("telescope.builtin")
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>e', ':Neotree filesystem reveal right<CR>')
vim.keymap.set("n", "<leader>fs", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")

local config = require("nvim-treesitter.configs")
config.setup({
    ensure_installed = {
        "lua", 
        "apex",
        "javascript",
        "soql",
        "sosl",
        "xml",
        "json",
        "python",
        "markdown",
    },
    highlight = {
        enable = true
    }
})

require('Comment').setup()

require("gitsigns").setup({
    signcolumn = false,
    current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d %H:%M> - <summary>',
    current_line_blame = true,
})

local wk = require("which-key")

wk.register({
    ["<leader>"] = {
        b = {
            name = "buffers",
            l = {
                "<cmd>lua require('telescope.builtin').buffers()<CR>", 
                "List Buffers"
            }
        },
        s = {
            name = "Salesforce",
            o = {
                name = "orgs",
                l = {          
                    "<cmd>SalesforceOrgPicker<CR>",
                    "List Orgs"
                }
            },
        },	
        a = {
            name = "Harpoon: mark current file"
        }
    }   
})

vim.filetype = on

vim.filetype.add({
  extension = {
    cls = 'apex',
    apex = 'apex',
    trigger = 'apex',
    soql = 'soql',
    sosl = 'sosl',
  }
})


local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local action_state = require('telescope.actions.state')
local actions = require('telescope.actions')

local function fetch_salesforce_orgs()
    local file_path = 'data/salesforce_orgs.txt'
    local file = io.open(file_path, "r")
    local orgs = {}
    if file then
        for line in file:lines() do
            local id, name = line:match("([^:]+):([^:]+)")
            table.insert(orgs, { id = id, name = name })
        end
        file:close()
    else
        print("Cannot open file: " .. file_path)
    end
    return orgs
end

local function entry_maker(entry)
    return {
        value = entry.id,
        display = entry.name,
        ordinal = entry.name,
    }
end

local function salesforce_org_picker()
    pickers.new({}, {
        prompt_title = 'Salesforce Orgs',
        finder = finders.new_table({
            results = fetch_salesforce_orgs(),
            entry_maker = entry_maker,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.api.nvim_put({selection.value}, "", false, true)
            end)
            return true
        end,
    }):find()
end

vim.api.nvim_create_user_command('SalesforceOrgPicker', salesforce_org_picker, {})

local function get_config_path()
    local home = os.getenv("HOME") or os.getenv("USERPROFILE")
    local os_name = vim.loop.os_uname().sysname
    return home
end

local config_path = get_config_path()

require('lualine').setup({
  options = {
    theme = 'dracula-nvim'
  }
})

require("mason").setup()

local harpoon = require("harpoon")
harpoon:setup()

vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)

local apex_jar_path = vim.fn.stdpath("config") .. '/lspserver/' .. 'apex-jorje-lsp.jar'

require'lspconfig'.apex_ls.setup {
  apex_jar_path = apex_jar_path,
  apex_enable_semantic_errors = true, 
  apex_enable_completion_statistics = true,
  filetypes = {'apex', 'cls', 'trigger'}
}


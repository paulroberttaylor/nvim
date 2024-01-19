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

local plugins = {
    {
        "ellisonleao/gruvbox.nvim"
    },
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        dependencies = { 
            'nvim-lua/plenary.nvim',
            "nvim-telescope/telescope-live-grep-args.nvim" ,
        }
    },
    {
        "nvim-treesitter/nvim-treesitter", 
        build = ":TSUpdate" 
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("telescope").load_extension("live_grep_args")
        end
    },
    { "lewis6991/gitsigns.nvim" },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "gruvbox"
        }
    },
    {
        "aserowy/tmux.nvim",
        config = function() 
            return require("tmux").setup() 
        end
    },
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
      end,
      opts = {
      }
   },
}


local opts = {}

require("lazy").setup(plugins, opts)

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
    },
    highlight = {
        enable = true
    }
})

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
    local file_path = 'data/salesforce_orgs.txt' -- Update with actual file path
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



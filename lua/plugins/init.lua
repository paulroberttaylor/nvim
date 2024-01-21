return {
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    },
    {
        "romainl/Apprentice"
    },
    {
        "folke/tokyonight.nvim"
    },
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
    {
        "kdheepak/lazygit.nvim",
        -- optional for floating window border decoration
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    },
    {
        'numToStr/Comment.nvim',
        opts = {
            -- add any options here
        },
        lazy = false,
    },
    {
        "williamboman/mason.nvim"
    },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" }
    },
}

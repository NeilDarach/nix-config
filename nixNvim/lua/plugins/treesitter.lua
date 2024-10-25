require("lze").load({
    "nvim-treesitter",
    event = "DeferredUIEnter",
    dep_of = { "treesj", "otter.nvm", "hlargs", "render-markdown", "neorg" },
    load = function(name)
        pcall(vim.cmd, "packadd " .. name)
        pcall(vim.cmd, "packadd nvim-treesitter-textobjects")
    end,
    after = function(plugin)
        vim.defer_fn(function()
            require("nvim-treesitter.configs").setup({
                highlight = {
                    enable = true,
                },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<CR>",
                        node_incremental = "<CR>",
                        node_decremental = "<bs>",
                        scope_incremental = "grc",
                    },
                },
                textobjects = {
                    select = {
                        enable = false,
                        lookahead = true,
                        keymaps = {
                            --  Not generally working.  Assignment doesn't seem to match, parameter is spotty
                            ['aa'] = { query = '@parameter.outer', desc = "Select [a] p[a]rameter" },
                            ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
                            ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
                            ["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
                            ["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },
                        }
                    },
                    move = {
                        enable = false,
                        set_jumps = true,
                        goto_next_start = {},
                        goto_next_end = {},
                        goto_previous_start = {},
                        goto_previous_end = {},
                    },
                    swap = {
                        enable = false,
                        swap_next = {},
                        swap_previous = {},
                    },
                },
            })
        end, 0)
    end,
})

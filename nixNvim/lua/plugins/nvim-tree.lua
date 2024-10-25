require("lze").load({ -- Filesystem browser
    "nvim-tree.nvim",
    keys = {
        { "<leader>fe", ":NvimTreeToggle<CR>", { desc = "NvimTree toggle" } },
    },
    event = "InsertEnter",
    after = function(plugin)
        require("nvim-tree").setup({
            disable_netrw = true,
            hijack_netrw = true,
            view = {
                number = true,
                relativenumber = true,

            },
            filters = {
                custom = { 'git' },
                exclude = { 'neogit.lua' },
            },
            actions = {
                open_file = {
                    quit_on_open = true,
                },
                change_dir = {
                    global = true
                },
            },
        })
    end,
})

require("lze").load({
    "gitsigns.nvim",
    --enabled = require("nixCatsUtils").enableForCategory("gitsigns"),
    event = "DeferredUIEnter",
    after = function(plugin)
        require("gitsigns").setup({
            on_attach = function(bufnr)
                local gs = require("gitsigns")
                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map({ "n", "v" }, "]c", function()
                    if vim.wo.diff then
                        return "]c"
                    end
                    vim.schedule(function()
                        gs.next_hunk()
                    end)
                    return "<Ignore>"
                end, { desc = "Jump to next git [c]hange" })

                map({ "n", "v" }, "[c", function()
                    if vim.wo.diff then
                        return "]c"
                    end
                    vim.schedule(function()
                        gs.prev_hunk()
                    end)
                    return "<Ignore>"
                end, { desc = "Jump to previous git [c]hange" })

                -- Actions
                -- Visual
                map("v", "<leader>hs", function()
                    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, { desc = "stage git hunk" })

                map("v", "<leader>hr", function()
                    gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, { desc = "reset git hunk" })
                -- Normal
                map("n", "<leader>gs", gs.stage_hunk, { desc = "[g]it [s]tage hunk" })
                map("n", "<leader>gr", gs.reset_hunk, { desc = "[g]it [r]eset hunk" })
                map("n", "<leader>gS", gs.stage_buffer, { desc = "[g]it [S]tage buffer" })
                map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "[g]it [u]ndo stage hunk" })
                map("n", "<leader>gR", gs.reset_buffer, { desc = "[g]it [R]eset buffer" })
                map("n", "<leader>gp", gs.preview_hunk, { desc = "[g]it [p]review hunk" })
                map("n", "<leader>gb", gs.blame_line, { desc = "[g]it [b]blame line" })
                map("n", "<leader>gd", gs.diffthis, { desc = "[g]it [d]iff against index" })
                map("n", "<leader>gD", function()
                    gs.diffthis("~")
                end, { desc = "[g]it [D]iff against last commit" })
                -- Toggles
                map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "[g]it [t]oggle show [b]lame" })
                map("n", "<leader>gtd", gs.toggle_deleted, { desc = "[g]it [t]oggle show [d]eleted" })
                -- Text object
                map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "select git hunk" })
            end,
        })
        vim.cmd([[hi GitSignsAdd guifg=#04de21]])
        vim.cmd([[hi GitSignsChange guifg=#83fce6]])
        vim.cmd([[hi GitSignsDelete guifg=#fa2525]])
        vim.cmd([[hi NonText guifg=#888888]])
    end,
})

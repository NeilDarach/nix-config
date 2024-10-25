require("nixCatsUtils").setup({
    non_nix_value = true,
})

vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smarttab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.wrap = false

-- leader must be defined before  plugins load
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- pull have_nerd_font from nix
vim.g.have_nerd_font = nixCats("have_nerd_font")

-- Line numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- mouse mode
vim.opt.mouse = ""

-- mode is already on the status line
vim.opt.showmode = false

-- sync clipboard to OS
vim.opt.clipboard = "unnamedplus"

if vim.g.neovide then
    vim.keymap.set("v", "<D-c>", '"+y')      -- Copy
    vim.keymap.set("n", "<D-v>", '"+P')      -- Paste normal mode
    vim.keymap.set("v", "<D-v>", '"+P')      -- Paste visual mode
    vim.keymap.set("c", "<D-v>", "<C-R>+")   -- Paste command mode
    vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode
end

-- Allow clipboard copy paste in neovim
vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })

-- Easy exit from leader state
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set({ "n" }, "q", "<Nop>", { silent = true })

-- Preserve indent for wrapped lines ??
vim.o.breakindent = false

-- save undo history
vim.o.undofile = true

-- case insensitive searching unless \C or a capital is in the search
vim.o.ignorecase = true
vim.o.smartcase = true

-- keep sign column on
vim.opt.signcolumn = "yes"

-- faster update
vim.opt.updatetime = 250

-- faster mapped sequence, which-key popup appears sooner
vim.opt.timeoutlen = 300

-- configure new splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- display certain whitespace
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- preview substitutions
vim.opt.inccommand = "split"

-- hilight current line
vim.opt.cursorline = true

-- keep context while scrolling
vim.opt.scrolloff = 5

-- Search elements say higlighted until cancelled
vim.o.hlsearch = true
vim.keymap.set("n", "<leader>h", "<CMD>nohlsearch<CR>")
vim.keymap.set("n", "<ESC>", "<CMD>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- exit terminal mode without <C-\><C-n>
vim.keymap.set("t", "<ESC><ESC>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Navigate vim panes better
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")

vim.o.termguicolors = true

-- Basic autocommand, see :help lua-guide-autocommands

-- Hilight when yanking text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Hilight when yanking text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Return to the last edited line on open
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = { "*" },
    callback = function(tbl)
        local tail = tbl.file:match("[^/]+$")
        if tail == "COMMIT_EDITMSG" then
            vim.api.nvim_exec("normal! 1G", false)
        else
            if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
                vim.api.nvim_exec("normal! g'\"", false)
            end
        end
    end
})



require("plugins")

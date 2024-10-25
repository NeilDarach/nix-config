local cmp = require('cmp')
local luasnip = require('luasnip')
luasnip.config.setup {}
local lspkind = require('lspkind')
cmp.setup({
    formatting = {
        format = lspkind.cmp_format {
            mode = 'text',
            with_text = true,
            maxwidth = 50,
            ellipsis_char = '...',
            menu = {
                buffer = '[BUF]',
                nvim_lsp_signature_help = '[LSP]',
                nvim_lsp_document_symbol = '[LSP]',
                nvim_lua = '[API]',
                path = '[PATH]',
                luasnip = '[SNIP]',
            },
        },
    },
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    completion = { completeopt = "menu,menuone,noinsert" },
    -- :help ins-completion
    mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.confirm({ select = true }),
        ["<C-l>"] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            end
        end, { "i", "s" }),
        ["<C-h>"] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            end
        end, { "i", "s" }),
    }),
    sources = {
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "luasnip" },
        { name = "path" },
        { name = "buffer" },
    },
    enabled = function()
        return vim.bo[0].buftype ~= 'prompt'
    end,
    experimental = { native_menu = false, ghost_text = false, }
})

cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'nvim_lsp_document_symbol' },
        { name = 'buffer' },
        { name = 'cmdline_history' },
    }
})

cmp.setup.cmdline({ ':' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'cmdline' },
        { name = 'path' },
    },
})

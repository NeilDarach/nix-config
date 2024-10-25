-- comment
local catUtils = require("nixCatsUtils")
local servers = {}


if nixCats("lua") then
    servers.lua_ls = {
        Lua = {
            formatters = {
                ignoreComments = true,
            },
            signatureHelp = { enabled = true },
            diagnostics = {
                globals = { "nixCats", "vim" },
                disable = { "missing-fields" },
            },
            workspace = { checkThirdParty = false },
            telemetry = { enabled = false },
        },
        filetypes = { "lua" },
    }
end

if nixCats("nix") then
    if catUtils.isNixCats then
        servers.nixd = {
            nixd = {
                nixpkgs = {
                    expr = [[import (builtins.getFlake "]] .. nixCats("nixdExtras.nixpkgs") .. [[") { } ]],
                },
                formatting = {
                    command = { "nixfmt" },
                },
                options = {
                    nixos = {
                        expr = [[(builtins.getFlake "]]
                            .. nixCats("nixdExtras.flake-path")
                            .. [[").legacyPackages.]]
                            .. nixCats("nixdExtras.system")
                            .. [[.nixosConfigurations."]]
                            .. nixCats("nixdExtras.systemCfgName")
                            .. [[".options]],
                    },
                },
                diagnostic = {
                    suppress = {
                        "sema-escaping-with",
                    },
                },
            },
        }
    else
        servers.rnix = {}
        servers.nil_ls = {}
    end
end

if nixCats("rust") and (os.execute('command -v rust-analyzer') == 0) then
    servers.rust_analyzer = {
    };
end

if nixCats("bash") then
    servers.bashls = {
        filetypes = { "sh" },
    }
end

local M = {}
function M.on_attach(_, bufnr)
    local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
    end

    map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
    map("gt", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
    map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementations")
    map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
    map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
    map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    --[[
					-- Highlight references of the word under the cursor when it rests there
					--      -- :help CursorHold
					--      -- The highlight is cleared when the cursor moves
					if client and client.server_capabilities.documentHighlightProvider then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detatch", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

				end,
			})
      ]]
    if vim.lsp.inlay_hint then
        vim.lsp.inlay_hint.enable(true)
        map("<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, "[T]oggle Inlay [H]ints")
    end
end

function M.get_capabilities(server_name)
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    if nixCats("general.cmp") then
        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
    end
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    return capabilities
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("nixCats-lsp-attach", { clear = true }),
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.semanticTokensProvider then
            client.server_capabilities.semanticTokensProvider = nil
        end
        M.on_attach(client, event.buf)
    end,
})

require("lze").load({
    {
        "nvim-lspconfig",
        event = "BufReadPre",
        dep_of = { "otter.nvim" },
        load = (catUtils.isNixCats and nil) or function(name)
            ---@diagnostic disable-next-line: param-type-mismatch
            pcall(vim.cmd, "packadd " .. name)
            ---@diagnostic disable-next-line: param-type-mismatch
            pcall(vim.cmd, "packadd mason.nvim")
            ---@diagnostic disable-next-line: param-type-mismatch
            pcall(vim.cmd, "packadd mason-lspconfig")
        end,
        after = function(plugin)
            if catUtils.isNixCats then
                for server_name, cfg in pairs(servers) do
                    require("lspconfig")[server_name].setup({
                        capabilities = M.get_capabilities(server_name),
                        settings = cfg,
                        filetypes = (cfg or {}).filetypes,
                        cmd = (cfg or {}).cmd,
                        root_pattern = (cfg or {}).root_pattern,
                    })
                end
            else
                require("mason").setup()
                local mason_lspconfig = require("mason-lspconfig")
                mason_lspconfig.setup({
                    ensure_installed = vim.tbl_keys(servers),
                })
                mason_lspconfig.setup_handlers({
                    function(server_name)
                        require("lspconfig")[server_name].setup({
                            capabilities = M.get_capabilities(server_name),
                            settings = servers[server_name],
                            filetypes = (servers[server_name] or {}).filetypes,
                        })
                    end,
                })
            end
        end,
    },
})

return M

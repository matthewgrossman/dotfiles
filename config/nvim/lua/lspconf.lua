local lsp = require'lspconfig'
local lsp_servers = {
    pyls={},
    tsserver={},
    clangd={}
}

for server, settings in pairs(lsp_servers) do
    lsp[server].setup{}
end

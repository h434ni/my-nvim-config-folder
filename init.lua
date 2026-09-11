require("config.lazy")

vim.cmd.colorscheme("koehler")


vim.opt.number = true
vim.opt.relativenumber = true


vim.opt.scrolloff = 10


vim.lsp.config("laravel_lsp", {
    cmd = { "laravel-lsp" },
    filetypes = { "php", "blade" },
    root_dir = function(bufnr, on_dir)
        local root = vim.fs.root(bufnr, "artisan")

        if root then
            on_dir(root)
        end
    end,
})
vim.lsp.enable("laravel_lsp")


vim.lsp.config('phpantom_lsp', {
  cmd = { 'phpantom_lsp' },
  filetypes = { 'php' },
  root_markers = { 'composer.json', '.git', '.phpantom.toml' },
})
vim.lsp.enable('phpantom_lsp')

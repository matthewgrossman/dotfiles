-- great resources https://github.com/lukas-reineke/dotfiles/tree/master/vim/lua/efm
local luaformat = {formatCommand = "lua-format -i", formatStdin = true}
local mypy = {
    lintCommand = "mypy --ignore-missing-imports --show-column-numbers",
    lintFormats = {'%f:%l:%c: %t%*[^:]: %m'},
    lintSource = "mypy"
}

local black = {formatCommand = "black --quiet -", formatStdin = true}
local reorderPythonImports = {
    formatCommand = "reorder-python-imports --exit-zero-even-if-changed -",
    formatStdin = true
}
local shellCheck = {
    lintCommand = "shellcheck -f gcc -x -",
    lintStdin = true,
    lintFormats = {
        "%f:%l:%c: %trror: %m", "%f:%l:%c: %tarning: %m", "%f:%l:%c: %tote: %m"
    },
    lintSource = "shellcheck"
}
local addTrailingComma = {
    formatCommand = "add-trailing-comma --py36-plus -",
    formatStdin = true
}

local luaCheck = {
    lintCommand = "luacheck --allow-defined --globals vim --globals hs --filename ${INPUT} --formatter plain -",
    lintStdin = true,
    lintFormats = {'%f:%l:%c: %m'}
}

return {
    lua = {luaCheck, luaformat},
    python = {black, reorderPythonImports, addTrailingComma, mypy},
    sh = {shellCheck},
    bash = {shellCheck},
    zsh = {shellCheck}
}

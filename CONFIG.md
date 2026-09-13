# Neovim Configuration Reference

The configuration requires Neovim 0.12 or newer and uses native LSP. The leader
and local leader are both `;`, so `<leader>ff` is typed as `;ff`.

## Capabilities

- Plugin management and lazy loading with lazy.nvim.
- Native LSP, diagnostics, inlay hints, code actions, code lenses, and document
  highlights.
- Completion with blink.cmp and LuaSnip, plus UltiSnips compatibility.
- Formatting with conform.nvim and an LSP fallback.
- Tree-sitter highlighting, indentation, text objects, and expandable selection.
- File and text search with fzf-lua, including a home-repository workaround.
- File browsing with nvim-tree and Git workflows with Fugitive.
- Flash navigation, comments, surrounds, persistent undo, and terminal runners.
- Tokyonight colors and a lualine statusline with LSP status.

## Global Keybindings

Modes use `n` for normal, `i` for insert, `x` for visual, `o` for
operator-pending, `s` for select, and `t` for terminal.

| Modes | Key | Action |
| --- | --- | --- |
| `i`, `x` | `kj` | Return to normal mode |
| `n` | `<C-h>` | Move to the left window |
| `n` | `<C-j>` | Move to the window below |
| `n` | `<C-k>` | Move to the window above |
| `n` | `<C-l>` | Move to the right window |
| `t` | `<C-w>` | Leave terminal mode and begin a window command |

## Search And Pickers

| Mode | Key | Action |
| --- | --- | --- |
| `n` | `<leader>ff` | Find files |
| `n` | `<leader>fg` | Live grep |
| `n` | `<leader>fb` | List buffers |
| `n` | `<leader>gs` | List Git files |
| `n` | `<leader>fo` | List recently opened files |
| `n` | `<leader>fr` | Resume the last picker |
| `n` | `<leader><Space>a` | List workspace diagnostics |
| `n` | `<leader><Space>e` | Open lazy.nvim |
| `n` | `<leader><Space>c` | Open the command palette |
| `n` | `<leader><Space>o` | List document symbols |
| `n` | `<leader><Space>s` | List workspace symbols |
| `n` | `<leader><Space>j` | Select the next quickfix item |
| `n` | `<leader><Space>k` | Select the previous quickfix item |
| `n` | `<leader><Space>p` | Resume the last picker |

Inside an fzf-lua picker, `<Tab>` moves down and `<S-Tab>` moves up. `<A-i>`
uses fzf-lua's ignore toggle.

The home directory is itself a Git repository with a global `*` ignore rule.
When that repository is the active root, file and grep pickers include hidden and
ignored files while excluding large generated directories and disk images. Real
projects below the home directory continue to respect their own ignore files.

## LSP

These mappings are installed only in buffers with an attached LSP client.

| Modes | Key | Action |
| --- | --- | --- |
| `n` | `gd` | Go to definition |
| `n` | `gD` | Go to declaration |
| `n` | `gy` | Go to type definition |
| `n` | `gi` | Go to implementation |
| `n` | `gr` | List references |
| `n` | `K` | Show hover information at the bottom-right of the editor |
| `n` | `[g`, `]g` | Go to the previous or next diagnostic |
| `n` | `<leader>rn` | Rename symbol |
| `n`, `x` | `<leader>f` | Format with conform.nvim and LSP fallback |
| `n` | `<leader>ca` | Show code actions |
| `n`, `x` | `<leader>a` | Show code actions |
| `n` | `<leader>as` | Show source code actions |
| `n` | `<leader>qf` | Apply a quick-fix code action |
| `n`, `x` | `<leader>r` | Show refactor code actions |
| `n` | `<leader>cl` | Run a code lens |
| `n` | `<leader>e` | Show diagnostics under the cursor |
| `n` | `<leader>oi` | Apply organize-imports actions |

LSP completion capabilities are supplied by blink.cmp. Inlay hints are enabled
when supported. Diagnostics use signs and underlines but no virtual text, are
severity-sorted, and do not update in insert mode. A non-focusable diagnostic
float opens after `updatetime` and closes when editing resumes. Supported clients
highlight references while the cursor is idle.

### Servers

| Language | Server | Installation and behavior |
| --- | --- | --- |
| Python | `basedpyright` | Types, completion, and hover; installed by Mason |
| Python | `ruff` | Diagnostics, quick fixes, and imports; installed by Mason |
| Go | `gopls` | Supplied by the Go toolchain |
| Lua | `lua_ls` | Supplied by mise; LuaJIT runtime, `vim` global, hints enabled |
| HTML | `html` | Installed by Mason |
| JSON | `jsonls` | Installed by Mason; SchemaStore schemas |
| YAML | `yamlls` | Installed by Mason; SchemaStore schemas |
| Rust | `rust-analyzer` | Managed by rustaceanvim rather than native LSP setup |

Python and Go root markers intentionally omit a bare `.git` marker so the home
repository is not treated as a language-server workspace. Rust enables proc
macros and Cargo output-directory loading.

## Completion And Snippets

| Mode | Key | Action |
| --- | --- | --- |
| `i` | `<CR>` | Accept the selected completion, otherwise fall back |
| `i` | `<Tab>` | Select the next completion, otherwise fall back |
| `i` | `<S-Tab>` | Select the previous completion, otherwise fall back |
| `i` | `<C-Space>` | Show completions |
| `i` | `<C-e>` | Hide completions |
| `i` | `<C-f>` | Scroll completion documentation down |
| `i` | `<C-b>` | Scroll completion documentation up |
| `i`, `s` | `<C-j>` | Expand an UltiSnips snippet or jump forward |
| `i`, `s` | `<C-k>` | Jump to the previous UltiSnips field |
| `x` | `<C-j>` | Capture visual text for UltiSnips |
| `i`, `s` | `<C-Tab>` | List UltiSnips snippets |

blink.cmp sources are LSP, paths, LuaSnip snippets, and buffer text. LuaSnip uses
friendly-snippets. UltiSnips separately loads vim-snippets for compatibility and
opens snippet editing in a vertical split. Completion documentation does not
open automatically.

## Flash Navigation

| Modes | Key | Action |
| --- | --- | --- |
| `n`, `x`, `o` | `s` | Flash jump |
| `n`, `o` | `S` | Flash Tree-sitter selection |
| `x` | `<leader>S` | Flash Tree-sitter selection |

The visual `S` mapping remains nvim-surround's standard mapping. Flash also
enhances native `f`, `F`, `t`, and `T`; its character mode does not display jump
labels by default.

The following EasyMotion-compatible prefixes all invoke the same general Flash
jump in normal, visual, and operator-pending modes:

```text
;;f  ;;F  ;;t  ;;T  ;;s  ;;w  ;;W  ;;b  ;;B
;;e  ;;E  ;;ge ;;gE ;;j  ;;k  ;;n  ;;N
```

## Tree-sitter Text Objects

Selection mappings work in visual and operator-pending modes.

| Key | Capture | Action |
| --- | --- | --- |
| `ac`, `ic` | `@comment.outer`, `@comment.inner` | Select a comment |
| `as`, `is` | `@string.outer`, `@string.inner` | Select a string or docstring |
| `af`, `if` | `@function.outer`, `@function.inner` | Select a function |
| `ak`, `ik` | `@class.outer`, `@class.inner` | Select a class |
| `aa`, `ia` | `@assignment.outer`, `@assignment.inner` | Select an assignment or its value |
| `av`, `iv` | `@assignment.lhs` | Select an assignment target |
| `aP`, `iP` | `@parameter.outer`, `@parameter.inner` | Select a parameter |
| `aC`, `iC` | `@call.outer`, `@call.inner` | Select a function call |

Movement mappings work in normal, visual, and operator-pending modes.

| Keys | Action |
| --- | --- |
| `]C`, `[C` | Next comment end or previous comment start |
| `]S`, `[S` | Next string end or previous string start |
| `]m`, `[m` | Next or previous function start |
| `]M`, `[M` | Next or previous function end |
| `]k`, `[k` | Next or previous class start |
| `]a`, `[a` | Next or previous assignment start |
| `]p`, `[p` | Next or previous parameter start |
| `]x`, `[x` | Next or previous function-call start |

`<C-s>` in normal or visual mode selects the current syntax node and repeatedly
expands to enclosing nodes. Some terminals require flow control to be disabled
with `stty -ixon` before `<C-s>` reaches Neovim.

The Python query adds inner and outer string captures for docstrings.

## Comments

| Modes | Key | Action |
| --- | --- | --- |
| `n`, `x` | `<leader>cc` | Toggle a line or selection |
| `n`, `x` | `<leader>c<Space>` | Toggle a line or selection |
| `n`, `x` | `<leader>cm` | Toggle block comments |
| `n`, `x` | `<leader>cu` | Uncomment |
| `n` | `<leader>c$` | Toggle a comment from the cursor to end of line |
| `n` | `<leader>cA` | Append a line comment at end of line |

Comment.nvim's enabled defaults are also available: `gcc`, `gbc`, `gc{motion}`,
`gb{motion}`, visual `gc` and `gb`, plus `gcO`, `gco`, and `gcA`.

## Surrounds

nvim-surround uses its standard mappings:

| Modes | Keys | Action |
| --- | --- | --- |
| `n` | `ys{motion}`, `yss` | Add a surround |
| `n` | `yS{motion}`, `ySS` | Add a surround on separate lines |
| `n` | `ds`, `cs`, `cS` | Delete or change a surround |
| `x` | `S`, `gS` | Surround a selection |
| `i` | `<C-g>s`, `<C-g>S` | Add a surround while inserting |

## File Tree

`<leader>n` toggles nvim-tree. The tree is 30 columns wide on the left, displays
dotfiles and Git-ignored files, and remains open after a file is selected.

Important tree-buffer mappings include:

| Keys | Action |
| --- | --- |
| `<CR>`, `o`, `l` | Open the selected node |
| `<BS>`, `h` | Close the parent directory |
| `q` | Close the tree |
| `<C-t>`, `<C-v>`, `<C-x>`, `<Tab>` | Open in a tab, splits, or preview |
| `a`, `d`, `<Del>`, `D` | Create, delete, or trash |
| `c`, `x`, `p`, `gp` | Copy, cut, paste, or move |
| `r`, `e`, `u`, `<C-r>` | Rename operations |
| `y`, `Y`, `gy`, `ge` | Copy names and paths |
| `<C-]>`, `-`, `P`, `<`, `>`, `J`, `K` | Root and sibling navigation |
| `E`, `W`, `R` | Expand, collapse, or reload |
| `B`, `C`, `H`, `I`, `M`, `U`, `f`, `F` | Filters and search |
| `m`, `bd`, `bt`, `bmv` | Marks and marked-file operations |
| `[c`, `]c`, `[e`, `]e` | Git and diagnostic navigation |
| `.`, `g?`, `L`, `O`, `s`, `S` | Run command, help, link, system-open, and info actions |

## Formatting

| Filetype | Formatter |
| --- | --- |
| Python | `ruff_format` |
| Rust | `rustfmt` |
| Go | `gofmt` |
| Lua | `stylua` |
| JSON, YAML, HTML | `prettier` |

Use `<leader>f` in an LSP buffer or `:Format`. If no configured formatter is
available, conform.nvim falls back to LSP formatting.

## Commands

### Configuration Commands

| Command | Scope | Action |
| --- | --- | --- |
| `:Format` | Global | Format the current buffer |
| `:Fold [level]` | Global | Close folds; optionally reopen to a fold level |
| `:OR` | Global | Organize imports using LSP code actions |
| `:PyRun [args...]` | Python buffer | Run the current file in a terminal |
| `:PyDebug [args...]` | Python buffer | Run the current file under `pdb` |
| `:PyTest [args...]` | Python buffer | Run pytest in a terminal |
| `:Pydoc [word]` | Python buffer | Show Python help for an argument or cursor word |

Finished Python run, debug, and test terminals bind `<CR>` to close the terminal.
While a process is running, Enter is passed through normally.

### Plugin Commands

- lazy.nvim: `:Lazy`.
- Mason: `:Mason`, `:MasonInstall`, `:MasonUninstall`, `:MasonUpdate`, and
  `:MasonLog`.
- fzf-lua: `:FzfLua`.
- conform.nvim: `:ConformInfo`.
- Tree-sitter: `:TSInstall`, `:TSUpdate`, `:TSUninstall`, and related parser
  management commands.
- nvim-tree: `:NvimTreeOpen`, `:NvimTreeClose`, `:NvimTreeToggle`,
  `:NvimTreeFocus`, `:NvimTreeRefresh`, `:NvimTreeFindFile`,
  `:NvimTreeFindFileToggle`, `:NvimTreeResize`, `:NvimTreeCollapse`, and
  `:NvimTreeCollapseKeepBuffers`.
- Fugitive: `:Git`, `:G`, `:Gdiffsplit`, `:Gvdiffsplit`, `:Gw`, `:Gwrite`,
  `:Gread`, `:Gblame`, `:Gedit`, `:Gsplit`, `:Gvsplit`, `:Gtabedit`, `:Ggrep`,
  `:GMove`, `:GRename`, `:GDelete`, and `:GBrowse`.
- rustaceanvim: `:RustLsp`, `:RustAnalyzer`, and `:Rustc`.
- UltiSnips: `:UltiSnipsEdit`, `:UltiSnipsAddFiletypes`,
  `:UltiSnipsRemoveFiletypes`, and `:UltiSnipsListLocations`.

## Language Behavior

| Filetype | Behavior |
| --- | --- |
| Python | Four-space expanded indentation and indent-based folds |
| Go | Four-column tabs with `expandtab` disabled |
| Rust | rustaceanvim LSP integration and rustfmt |
| Lua | LuaJIT-aware LSP, hints, and stylua |
| HTML, JSON, YAML | Language servers, schemas where applicable, and prettier |

Installed Tree-sitter parsers are HTML, JSON, YAML, Python, Rust, Go, Lua, Vim,
Vimdoc, Bash, Markdown, and Markdown inline. Highlighting starts on `FileType`;
Tree-sitter indentation is enabled only when a parser successfully starts.

## Options

| Option | Value |
| --- | --- |
| `number` | `true` |
| `updatetime`, `timeoutlen` | `300` ms |
| `signcolumn` | `yes` |
| `mouse` | `a` |
| `tabstop`, `softtabstop`, `shiftwidth` | `4` |
| `expandtab`, `smartindent` | `true` |
| `wrap` | `false` |
| `scrolloff` | `8` |
| `colorcolumn` | `80` |
| `termguicolors` | `true` |
| `hlsearch`, `incsearch` | `false`, `true` |
| `undofile` | `true`, stored under `stdpath("state")/undo` |
| `completeopt` | `menu,menuone,noselect` |

Yanked text is highlighted for 200 ms.

## Environment And Loading

The mise shim directory is prepended to `PATH` when present. It supplies `fd`,
`prettier`, `lua-language-server`, and `stylua`. The Python provider is pinned to
`~/.pyenv/versions/3.12.9/bin/python` when executable because that environment
contains pynvim for UltiSnips.

lazy.nvim bootstraps itself with Git when missing. Tokyonight, nvim-tree,
Tree-sitter, Mason, lspconfig, and UltiSnips load at startup. Comments, formatting,
Flash, and surrounds load on `VeryLazy`; text objects load when files are opened;
lualine loads on `UIEnter`; rustaceanvim loads for Rust; Fugitive loads on its
configured commands. blink.cmp and fzf-lua also load at startup.

The disabled built-in plugins are gzip, matchit, matchparen, netrwPlugin,
tarPlugin, tohtml, tutor, and zipPlugin.

## Plugins

| Plugin | Purpose |
| --- | --- |
| `folke/lazy.nvim` | Plugin manager |
| `folke/tokyonight.nvim` | Colorscheme |
| `nvim-lualine/lualine.nvim` | Statusline |
| `nvim-tree/nvim-web-devicons` | Icons |
| `nvim-tree/nvim-tree.lua` | File tree |
| `nvim-treesitter/nvim-treesitter` | Parsing, highlighting, and indentation |
| `nvim-treesitter/nvim-treesitter-textobjects` | Syntax-aware text objects |
| `neovim/nvim-lspconfig` | Native LSP server definitions |
| `mason-org/mason.nvim` | External tool installer |
| `mason-org/mason-lspconfig.nvim` | Mason/LSP integration |
| `b0o/schemastore.nvim` | JSON and YAML schemas |
| `saghen/blink.cmp` | Completion |
| `L3MON4D3/LuaSnip` | Completion snippet engine |
| `rafamadriz/friendly-snippets` | LuaSnip snippet collection |
| `SirVer/ultisnips` | Compatibility snippet engine |
| `honza/vim-snippets` | UltiSnips snippet collection |
| `ibhagwan/fzf-lua` | Fuzzy finding and LSP pickers |
| `stevearc/conform.nvim` | Formatting |
| `numToStr/Comment.nvim` | Comments |
| `kylechui/nvim-surround` | Surround editing |
| `folke/flash.nvim` | Labeled navigation |
| `tpope/vim-fugitive` | Git commands |
| `mrcjkb/rustaceanvim` | Rust language integration |

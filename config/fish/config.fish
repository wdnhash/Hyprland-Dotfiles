# ╔══════════════════════════════════════════════════════════════╗
# ║                     FISH  —  mono #1a1a1a                      ║
# ╚══════════════════════════════════════════════════════════════╝
# Local: ~/.config/fish/config.fish
# Requer (opcionais): starship, eza, zoxide, fzf  →  pacman -S ...
#
# ⚠ CachyOS: se você tem o pacote `cachyos-fish-config`, ele já mexe
#   nesse arquivo. Faça backup do atual antes de substituir:
#     cp ~/.config/fish/config.fish ~/.config/fish/config.fish.bak

if status is-interactive

    # ───────────── básico ─────────────
    set -g fish_greeting ""                 # sem saudação
    set -gx EDITOR  "zed --wait"
    set -gx VISUAL  "zed --wait"
    set -gx MANPAGER "less -R"

    fish_add_path ~/.local/bin
    fish_add_path ~/.cargo/bin

    # ───────────── cores (escala de cinza) ─────────────
    set -g fish_color_normal          d4d4d4
    set -g fish_color_command         f0f0f0
    set -g fish_color_keyword         bbbbbb
    set -g fish_color_quote           8a8a8a
    set -g fish_color_redirection     bbbbbb
    set -g fish_color_end             8a8a8a
    set -g fish_color_error           f5f5f5 --bold
    set -g fish_color_param           d4d4d4
    set -g fish_color_comment         5a5a5a
    set -g fish_color_operator        bbbbbb
    set -g fish_color_escape          969696
    set -g fish_color_autosuggestion  5a5a5a
    set -g fish_color_selection       --background=3a3a3a
    set -g fish_color_search_match    --background=3a3a3a
    set -g fish_color_cwd             bbbbbb
    set -g fish_color_user            8a8a8a
    set -g fish_color_host            8a8a8a

    set -g fish_pager_color_prefix              f0f0f0 --bold
    set -g fish_pager_color_completion          d4d4d4
    set -g fish_pager_color_description         6e6e6e
    set -g fish_pager_color_selected_background --background=3a3a3a

    # ───────────── abbreviations (expandem com espaço) ─────────────
    # paru / pacman
    abbr -a up   'paru -Syu'
    abbr -a inst 'paru -S'
    abbr -a rem  'paru -Rns'
    abbr -a ser  'paru -Ss'
    abbr -a orph 'paru -Qtdq'           # lista pacotes órfãos
    abbr -a pql  'pacman -Qe'           # instalados explicitamente

    # git
    abbr -a g    'git'
    abbr -a gs   'git status -sb'
    abbr -a ga   'git add'
    abbr -a gaa  'git add --all'
    abbr -a gc   'git commit'
    abbr -a gcm  'git commit -m'
    abbr -a gp   'git push'
    abbr -a gl   'git pull'
    abbr -a glog 'git log --oneline --graph --decorate'
    abbr -a gd   'git diff'
    abbr -a gco  'git checkout'
    abbr -a gb   'git branch'

    # navegação
    abbr -a ..   'cd ..'
    abbr -a ...  'cd ../..'
    abbr -a .... 'cd ../../..'

    # ───────────── aliases ─────────────
    alias c    'clear'
    alias ff   'fastfetch'
    # `command` evita recursão (função chamando a si mesma)
    alias grep 'command grep --color=auto'
    alias ip   'command ip --color=auto'

    # ls: usa eza se existir; senão, coreutils
    if type -q eza
        alias ls   'eza --group-directories-first --icons=auto'
        alias ll   'eza -lah --group-directories-first --icons=auto --git'
        alias tree 'eza --tree --icons=auto'
    else
        alias ls 'command ls --color=auto --group-directories-first'
        alias ll 'command ls -lah --color=auto --group-directories-first'
    end

    # ───────────── integrações (só se instaladas) ─────────────
    type -q starship; and starship init fish | source
    type -q zoxide;   and zoxide init fish | source     # `z pasta` p/ pular
    type -q fzf;      and fzf --fish | source

    # fastfetch ao abrir o terminal (descomente se quiser)
    # fastfetch
end

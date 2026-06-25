# dotfiles — CachyOS • Hyprland • Noctalia (mono #1a1a1a)

Paleta: base `#1a1a1a` • surface `#242424` • border `#2e2e2e` • muted `#4a4a4a` • text `#d4d4d4` • accent `#6e6e6e`

## Como usar

```bash
chmod +x postinstall.sh
./postinstall.sh                      # interativo
./postinstall.sh --noconfirm          # aceita os padrões
GPU=amd ./postinstall.sh --noconfirm  # GPU pré-definida (nvidia|amd|intel|vm|skip)
```

O script pergunta no começo e depois roda sozinho:

| Opção | O que faz |
|---|---|
| **Driver de vídeo** | Nvidia (open modules + KMS), AMD, Intel, VM (detecta QEMU/VirtualBox/VMware e instala guest tools) ou pular |
| Apps pessoais | discord, zed, obsidian, spotify, zen-browser, onlyoffice |
| Gaming | steam, gamemode, mangohud, gamescope + libs 32-bit da GPU escolhida |
| Apps GNOME | nautilus, calculadora, evince etc. |
| Flatpak | + Bitwarden |
| Claude Code | CLI da Anthropic |

Depois instala o resto (Hyprland, Noctalia, fontes, temas), extrai ícones/cursor e **symlinka** as configs — editar em `~/.config` é editar aqui no repo. Não mova nem apague esta pasta depois de rodar.

> Usando GPU que não é Nvidia? Comente as env vars de Nvidia no `config/hypr/hyprland.lua` (o script avisa). Ajuste também os monitores (`hyprctl monitors all`).

## Estrutura

```
postinstall.sh            instala tudo e cria os symlinks
config/                   espelha ~/.config (uma pasta por app)
├── alacritty/            terminal
├── fastfetch/            fetch minimalista
├── fish/                 shell
├── gtk/                  settings.ini (tema, ícones, sem botões de janela)
├── hypr/                 hyprland.lua
├── noctalia/             scheme Monochrome → colorschemes/Monochrome/
├── qt6ct/                paleta Qt mono (qt6ct.conf é gerado pelo script)
├── starship/             prompt
└── zed/                  settings.json (keymap.macos.json não é deployado)
themes/
├── gtk/adw-gtk3-dark/    tema GTK com overrides mono → ~/.themes
├── icons/                Colloid (tar.xz) → ~/.local/share/icons
└── cursors/              Bibata-Original-Classic (tar.xz) → ~/.local/share/icons
wallpapers/               → ~/Pictures/wallpapers
```

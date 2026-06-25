#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║         POS-INSTALL — CachyOS + Hyprland + Noctalia           ║
# ║                  mono #1a1a1a • fish shell                     ║
# ╚══════════════════════════════════════════════════════════════╝
#
# Uso:
#   chmod +x postinstall.sh
#   ./postinstall.sh                 # interativo (recomendado na 1ª vez)
#   ./postinstall.sh --noconfirm     # aceita os padrões sem perguntar
#
# Não-interativo / pré-respondido por variável de ambiente:
#   GPU=nvidia ./postinstall.sh --noconfirm     # nvidia|amd|intel|vm|skip
#
# Idempotente: pode rodar de novo sem quebrar (usa --needed).
# NÃO rode como root. Ele chama sudo onde precisa.
#
# Premissa: CachyOS (edição Hyprland) já traz a base — Hyprland, Noctalia,
# PipeWire, NetworkManager, fontes, utilitários Wayland, etc. Aqui só
# instalamos os softwares PESSOAIS. Precisa de algo a mais? Adicione na
# lista PKG_APPS / AUR_APPS abaixo.
#
# As configs são COPIADAS pras pastas padrão (~/.config etc.). Editar lá
# NÃO altera o repo — reedite aqui e rode o script de novo pra atualizar.

set -euo pipefail

# ───────────── helpers ─────────────
C_OK="\033[1;32m"; C_INFO="\033[1;34m"; C_WARN="\033[1;33m"; C_ERR="\033[1;31m"; C_OFF="\033[0m"
log()  { echo -e "${C_INFO}::${C_OFF} $*"; }
ok()   { echo -e "${C_OK}✓${C_OFF} $*"; }
warn() { echo -e "${C_WARN}!${C_OFF} $*"; }
die()  { echo -e "${C_ERR}✗ $*${C_OFF}"; exit 1; }

[[ $EUID -eq 0 ]] && die "Não rode como root. Rode como seu usuário (vai pedir sudo)."
command -v pacman >/dev/null || die "pacman não encontrado — isso é pra Arch/CachyOS."

NOCONFIRM=""
[[ "${1:-}" == "--noconfirm" ]] && NOCONFIRM="--noconfirm"

# pergunta sim/não; com --noconfirm usa o padrão
ask_yn() {  # ask_yn "pergunta" "s|n"  →  retorna 0 (sim) / 1 (não)
    local prompt="$1" default="${2:-s}" reply
    if [[ -n "$NOCONFIRM" ]]; then
        reply="$default"
    else
        read -rp "$(echo -e "${C_INFO}?${C_OFF}") $prompt [s/n] (padrão: $default): " reply
        reply="${reply:-$default}"
    fi
    [[ "${reply,,}" == s* || "${reply,,}" == y* ]]
}

# ═══════════════════════════════════════════════════════════════
#  PERGUNTAS — tudo decidido aqui; depois o script roda sozinho
# ═══════════════════════════════════════════════════════════════
echo
log "Algumas escolhas antes de começar:"
echo

# ── driver de vídeo ──
GPU="${GPU:-}"
if [[ -z "$GPU" ]]; then
    if [[ -n "$NOCONFIRM" ]]; then
        GPU="skip"
    else
        echo "  Driver de vídeo:"
        echo "    1) Nvidia   (open modules — GTX 16xx / RTX em diante)"
        echo "    2) AMD      (mesa + vulkan-radeon)"
        echo "    3) Intel    (mesa + vulkan-intel)"
        echo "    4) VM       (QEMU/KVM, VirtualBox, VMware — detecta sozinho)"
        echo "    5) Pular    (driver já instalado / cuido depois)"
        read -rp "  Escolha [1-5]: " gpu_choice
        case "${gpu_choice:-5}" in
            1) GPU="nvidia" ;;
            2) GPU="amd"    ;;
            3) GPU="intel"  ;;
            4) GPU="vm"     ;;
            *) GPU="skip"   ;;
        esac
    fi
fi
echo

# ── grupos opcionais ──
WANT_APPS=0;    ask_yn "Apps pessoais (discord, zed, obsidian, spotify, zen-browser, onlyoffice)?" s && WANT_APPS=1
WANT_GAME=0;    ask_yn "Gaming (steam, gamemode, mangohud, gamescope + libs 32-bit)?" s && WANT_GAME=1
WANT_GNOME=0;   ask_yn "Apps GNOME (nautilus, calculadora, evince, etc. — no lugar dos do KDE)?" s && WANT_GNOME=1
WANT_FLATPAK=0; ask_yn "Flatpak + Bitwarden?" s && WANT_FLATPAK=1
WANT_CLAUDE=0;  ask_yn "Claude Code (CLI da Anthropic)?" s && WANT_CLAUDE=1
echo
ok "GPU: $GPU • apps:$WANT_APPS gaming:$WANT_GAME gnome:$WANT_GNOME flatpak:$WANT_FLATPAK claude:$WANT_CLAUDE"

# ───────────── 1. update do sistema ─────────────
log "Atualizando o sistema..."
sudo pacman -Syu $NOCONFIRM
ok "Sistema atualizado."

# ───────────── 2. base-devel + git (pra AUR) ─────────────
sudo pacman -S --needed $NOCONFIRM base-devel git

# ───────────── 3. AUR helper (paru) ─────────────
if command -v paru >/dev/null; then
    ok "paru já instalado."
else
    log "Instalando paru (AUR helper)..."
    tmp="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru.git "$tmp/paru"
    ( cd "$tmp/paru" && makepkg -si --needed --noconfirm )
    rm -rf "$tmp"
    ok "paru instalado."
fi

# ───────────── 4. multilib (necessário p/ gaming e libs 32-bit) ─────────────
if grep -q '^\[multilib\]' /etc/pacman.conf; then
    ok "multilib já habilitado."
else
    warn "Habilitando [multilib] em /etc/pacman.conf..."
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    sudo pacman -Syu $NOCONFIRM
fi

# ═══════════════════════════════════════════════════════════════
#  PACOTES DE REPOSITÓRIO (pacman)
#  Só softwares pessoais — a base (Hyprland, Noctalia, PipeWire,
#  fontes, utilitários Wayland) já vem no CachyOS. Falta algo?
#  É só acrescentar na lista certa aqui embaixo.
# ═══════════════════════════════════════════════════════════════

# Terminal / shell que os dotfiles usam (sempre instalados)
PKG_APPS=(
    alacritty                # terminal
    fish                     # shell
    starship                 # prompt
    eza                      # ls moderno (aliases ls/ll/tree)
    zoxide                   # `z pasta` p/ pular
    fzf                      # fuzzy finder
    fastfetch                # fetch minimalista
)
[[ $WANT_APPS -eq 1 ]] && PKG_APPS+=(
    discord zed obsidian
    spotify-launcher         # versão "oficial" do Spotify (melhor que o do AUR)
)

# Apps GNOME (preferência sua no lugar dos padrões do KDE)
PKG_GNOME=(
    nautilus                 # gerenciador de arquivos
    gvfs gvfs-mtp gvfs-smb   # montagem/lixeira/rede/celular no nautilus
    sushi                    # preview rápido (barra de espaço no nautilus)
    ffmpegthumbnailer        # miniaturas de vídeo
    gnome-text-editor gnome-calculator gnome-disk-utility
    gnome-system-monitor baobab loupe evince file-roller
    gnome-keyring            # chaveiro (senhas, ssh keys, git creds)
)

PKG_GAME=(
    steam
    vulkan-icd-loader lib32-vulkan-icd-loader
    gamemode lib32-gamemode
    mangohud lib32-mangohud
    gamescope
)

# ── driver de vídeo conforme a escolha ──
PKG_GPU=()
PKG_GPU32=()   # libs 32-bit (só entram se gaming = sim)
case "$GPU" in
    nvidia)
        PKG_GPU=(nvidia-open-dkms nvidia-utils nvidia-settings egl-wayland libva-nvidia-driver)
        PKG_GPU32=(lib32-nvidia-utils)
        ;;
    amd)
        PKG_GPU=(mesa vulkan-radeon libva-mesa-driver mesa-vdpau)
        PKG_GPU32=(lib32-mesa lib32-vulkan-radeon)
        ;;
    intel)
        PKG_GPU=(mesa vulkan-intel intel-media-driver)
        PKG_GPU32=(lib32-mesa lib32-vulkan-intel)
        ;;
    vm)
        PKG_GPU=(mesa)
        PKG_GPU32=(lib32-mesa)
        ;;
esac

# monta a lista final
PKGS=( "${PKG_APPS[@]}" "${PKG_GPU[@]}" )
[[ $WANT_GNOME -eq 1 ]] && PKGS+=( "${PKG_GNOME[@]}" )
[[ $WANT_GAME  -eq 1 ]] && PKGS+=( "${PKG_GAME[@]}" "${PKG_GPU32[@]}" )

log "Instalando pacotes de repositório..."
sudo pacman -S --needed $NOCONFIRM "${PKGS[@]}"
ok "Pacotes de repositório instalados."

# ═══════════════════════════════════════════════════════════════
#  PÓS-DRIVER — ajustes específicos da GPU escolhida
# ═══════════════════════════════════════════════════════════════
case "$GPU" in
    nvidia)
        # KMS: necessário pro Hyprland funcionar direito com Nvidia
        if [[ ! -f /etc/modprobe.d/nvidia-kms.conf ]]; then
            echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee /etc/modprobe.d/nvidia-kms.conf >/dev/null
            ok "KMS habilitado (/etc/modprobe.d/nvidia-kms.conf)."
        fi
        warn "Falta só o initramfs (manual, com cuidado):"
        echo "    adicione 'nvidia nvidia_modeset nvidia_uvm nvidia_drm' aos MODULES"
        echo "    do mkinitcpio.conf (ou dracut) e regenere. Depois reinicie."
        ;;
    amd|intel|vm)
        warn "O config/hypr/hyprland.lua tem env vars específicas de Nvidia."
        echo "    Comente as linhas LIBVA_DRIVER_NAME / __GLX_VENDOR_LIBRARY_NAME /"
        echo "    NVD_BACKEND / GBM_BACKEND antes de logar no Hyprland."
        ;;
esac

# VM: guest tools conforme o hypervisor (detectado automaticamente)
if [[ "$GPU" == "vm" ]] && command -v systemd-detect-virt >/dev/null; then
    VIRT="$(systemd-detect-virt || true)"
    case "$VIRT" in
        kvm|qemu)
            sudo pacman -S --needed $NOCONFIRM qemu-guest-agent spice-vdagent
            sudo systemctl enable --now qemu-guest-agent.service 2>/dev/null || true
            ok "Guest tools QEMU/KVM instalados." ;;
        oracle)
            sudo pacman -S --needed $NOCONFIRM virtualbox-guest-utils
            sudo systemctl enable --now vboxservice.service 2>/dev/null || true
            ok "Guest tools VirtualBox instalados." ;;
        vmware)
            sudo pacman -S --needed $NOCONFIRM open-vm-tools
            sudo systemctl enable --now vmtoolsd.service 2>/dev/null || true
            ok "Guest tools VMware instalados." ;;
        *)
            warn "Hypervisor não detectado ($VIRT) — instale os guest tools manualmente." ;;
    esac
fi

# ═══════════════════════════════════════════════════════════════
#  PACOTES DO AUR (paru) — só apps pessoais; review do PKGBUILD recomendado
#  (Noctalia já vem no CachyOS, não instalamos aqui)
# ═══════════════════════════════════════════════════════════════
AUR_PKGS=()
if [[ $WANT_APPS -eq 1 ]]; then
    AUR_PKGS+=(
        zen-browser-bin      # use o -bin: o pacote source costuma falhar no build
        onlyoffice-bin       # suíte office (docx/xlsx/pptx)
    )
fi
if [[ ${#AUR_PKGS[@]} -gt 0 ]]; then
    log "Instalando pacotes do AUR..."
    paru -S --needed "${AUR_PKGS[@]}"
    ok "Pacotes do AUR instalados."
else
    ok "Nenhum pacote do AUR a instalar."
fi

# ═══════════════════════════════════════════════════════════════
#  FLATPAK — Bitwarden
# ═══════════════════════════════════════════════════════════════
if [[ $WANT_FLATPAK -eq 1 ]]; then
    log "Configurando Flatpak + Flathub..."
    sudo pacman -S --needed $NOCONFIRM flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub com.bitwarden.desktop
    ok "Bitwarden (flatpak) instalado."
fi

# ═══════════════════════════════════════════════════════════════
#  CLAUDE CODE (CLI da Anthropic)
# ═══════════════════════════════════════════════════════════════
if [[ $WANT_CLAUDE -eq 1 ]]; then
    if command -v claude >/dev/null; then
        ok "Claude Code já instalado."
    else
        log "Instalando Claude Code..."
        curl -fsSL https://claude.ai/install.sh | bash
        ok "Claude Code instalado (binário em ~/.local/bin)."
    fi
fi

# ═══════════════════════════════════════════════════════════════
#  FISH como shell padrão
# ═══════════════════════════════════════════════════════════════
FISH_BIN="$(command -v fish || true)"
if [[ -n "$FISH_BIN" && "$SHELL" != "$FISH_BIN" ]]; then
    log "Definindo fish como shell padrão..."
    grep -qx "$FISH_BIN" /etc/shells || echo "$FISH_BIN" | sudo tee -a /etc/shells >/dev/null
    chsh -s "$FISH_BIN"
    ok "Shell padrão = fish (vale a partir do próximo login)."
else
    ok "fish já é o shell padrão (ou não instalado)."
fi

# ═══════════════════════════════════════════════════════════════
#  DOTFILES → copiados pras pastas padrão (backup .bak na 1ª vez)
# ═══════════════════════════════════════════════════════════════
DOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log "Copiando configs pras pastas padrão..."

deploy() {  # deploy <origem> <destino>  — copia (arquivo ou pasta)
    local src="$1" dst="$2"
    [[ -e "$src" ]] || { warn "não achei $(basename "$src") — pulando"; return 0; }
    mkdir -p "$(dirname "$dst")"
    # backup só na primeira vez (não sobrescreve um .bak já existente)
    if [[ -e "$dst" && ! -e "$dst.bak" ]]; then
        cp -a "$dst" "$dst.bak"
    fi
    rm -rf "$dst"
    cp -a "$src" "$dst"
    ok "→ ${dst/#$HOME/\~}"
}

deploy "$DOT_DIR/config/hypr/hyprland.lua"        "$HOME/.config/hypr/hyprland.lua"
deploy "$DOT_DIR/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
deploy "$DOT_DIR/config/fish/config.fish"         "$HOME/.config/fish/config.fish"
deploy "$DOT_DIR/config/starship/starship.toml"   "$HOME/.config/starship.toml"
deploy "$DOT_DIR/config/fastfetch/fastfetch.jsonc" "$HOME/.config/fastfetch/config.jsonc"
deploy "$DOT_DIR/config/zed/settings.json"        "$HOME/.config/zed/settings.json"
deploy "$DOT_DIR/wallpapers"                      "$HOME/Pictures/wallpapers"

# Noctalia: schemes customizados vivem em ~/.config/noctalia/colorschemes/<Nome>/<Nome>.json
deploy "$DOT_DIR/config/noctalia/MonochromeNoctalia.json" \
       "$HOME/.config/noctalia/colorschemes/Monochrome/Monochrome.json"

# GTK: tema + sem botões de janela (CSD) — settings.ini p/ GTK3/4
deploy "$DOT_DIR/config/gtk/gtk-settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
deploy "$DOT_DIR/config/gtk/gtk-settings.ini" "$HOME/.config/gtk-4.0/settings.ini"

# Tema GTK mono → ~/.themes (depois aplique com nwg-look)
deploy "$DOT_DIR/themes/gtk/adw-gtk3-dark" "$HOME/.themes/adw-gtk3-dark"

# Qt (qt6ct): paleta mono
deploy "$DOT_DIR/config/qt6ct/mono.conf" "$HOME/.config/qt6ct/colors/mono.conf"

ok "Configs copiadas."

# ═══════════════════════════════════════════════════════════════
#  QT6CT — gerado aqui (precisa de path absoluto pro scheme)
# ═══════════════════════════════════════════════════════════════
mkdir -p "$HOME/.config/qt6ct"
cat > "$HOME/.config/qt6ct/qt6ct.conf" <<QTEOF
[Appearance]
style=Fusion
custom_palette=true
color_scheme_path=$HOME/.config/qt6ct/colors/mono.conf
icon_theme=Colloid-Dark
standard_dialogs=gtk3

[Fonts]
fixed="JetBrainsMono Nerd Font,11"
general="Noto Sans,11"
QTEOF
ok "qt6ct.conf gerado (Fusion + paleta mono + ícones Colloid-Dark)."

# ═══════════════════════════════════════════════════════════════
#  GSETTINGS — apps libadwaita leem daqui (via portal), não do .ini
# ═══════════════════════════════════════════════════════════════
if command -v gsettings >/dev/null; then
    gsettings set org.gnome.desktop.wm.preferences button-layout ':' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme 'Colloid-Dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Original-Classic' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    ok "gsettings aplicados (botões de janela ocultos, tema, ícones, cursor)."
fi

# ═══════════════════════════════════════════════════════════════
#  SERVIÇOS
# ═══════════════════════════════════════════════════════════════
log "Habilitando serviços..."
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now power-profiles-daemon.service
ok "Serviços habilitados."

# ───────────── fim ─────────────
echo
ok  "Tudo pronto!"
echo -e "${C_WARN}Próximos passos manuais:${C_OFF}"
echo "  • Configs COPIADAS — pra atualizar depois, reedite o repo e rode o script de novo"
echo "  • Rode 'hyprctl monitors all' e ajuste os monitores em ~/.config/hypr/hyprland.lua"
echo "    (nomes dos outputs, resolução e posição são do setup original)"
echo "  • No Noctalia: Settings → Colors → selecione 'Monochrome'"
echo "  • Confira tema/ícones/cursor no nwg-look (adw-gtk3-dark / Colloid-Dark / Bibata)"
[[ "$GPU" == "nvidia" ]] && echo "  • Nvidia: configure o initramfs (instruções acima) e reinicie"
[[ "$GPU" == "amd" || "$GPU" == "intel" || "$GPU" == "vm" ]] && \
echo "  • Comente as env vars de Nvidia no config/hypr/hyprland.lua"
echo "  • Faça logout/login pro fish e o shell entrarem em vigor"

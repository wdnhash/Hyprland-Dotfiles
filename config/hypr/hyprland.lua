-- ╔══════════════════════════════════════════════════════════════╗
-- ║                  HYPRLAND - CONFIG (Lua)                       ║
-- ║   Tema mono #1a1a1a • dwindle (BSPWM-like) • RTX 4060          ║
-- ║   Shell: noctalia (barra/launcher/notif/lock/idle/wallpaper)   ║
-- ╚══════════════════════════════════════════════════════════════╝
--
-- Paleta (também usada em temas do Noctalia):
--   Base       #1a1a1a    Surface  #242424    Border  #2e2e2e
--   Muted      #4a4a4a    Text     #d4d4d4    Accent  #6e6e6e
-- Documentação: https://wiki.hypr.land  |  https://docs.noctalia.dev


-- ───────────── MONITORES ─────────────
-- ⚠ Descubra os nomes REAIS dos seus outputs antes:   hyprctl monitors all
--   (e as classes de janela com:                      hyprctl clients     )
--
-- Layout desejado:
--   [ 1080p VERTICAL ] [ ───── 4K horizontal (primário) ───── ]
--        à esquerda                centro / principal
--
-- Primário: 4K @100Hz, scale 1.5 (≈2560x1440 lógico). Fica à direita do vertical.
-- O x=1080 do primário = largura lógica do vertical (1080p girado = 1080 de largura).
hl.monitor({ output = "DP-1",     mode = "3840x2160@100", position = "1080x0", scale = "1.5" })

-- Secundário: 1080p @100Hz, VERTICAL à esquerda.
-- transform: 1 = 90° (horário) | 3 = 270° (anti-horário).
-- Se a tela ficar de cabeça pra baixo, troque 3 ↔ 1.
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@100", position = "0x0",    scale = "1", transform = 3 })

-- Fallback p/ qualquer monitor extra não listado:
hl.monitor({ output = "",         mode = "preferred",     position = "auto",   scale = "auto" })


-- ───────────── ENV (Nvidia RTX 4060 + Wayland + Qt/GTK) ─────────────
-- Render/aceleração Nvidia (drivers já instalados pelo script de pós-install)
hl.env("LIBVA_DRIVER_NAME",              "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME",      "nvidia")
hl.env("NVD_BACKEND",                    "direct")
-- GBM_BACKEND: deixe nvidia-drm. Se tiver flicker/tela preta em alguns apps,
-- comentar esta linha às vezes resolve (varia por versão do driver).
hl.env("GBM_BACKEND",                    "nvidia-drm")
hl.env("ELECTRON_OZONE_PLATFORM_HINT",   "auto")

hl.env("XDG_SESSION_TYPE",               "wayland")
hl.env("XDG_CURRENT_DESKTOP",            "Hyprland")
hl.env("XDG_SESSION_DESKTOP",            "Hyprland")

hl.env("QT_QPA_PLATFORM",                "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME",           "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_BACKEND",                    "wayland,x11")

hl.env("XCURSOR_THEME",                  "Bibata-Original-Classic")
hl.env("XCURSOR_SIZE",                   "24")
hl.env("HYPRCURSOR_THEME",               "Bibata-Original-Classic")
hl.env("HYPRCURSOR_SIZE",                "24")

hl.env("TERMINAL",                       "alacritty")
hl.env("GTK_THEME",                      "adw-gtk3-dark")


-- ───────────── PROGRAMAS ─────────────
local terminal    = "alacritty"
local fileManager = "nautilus"
local browser     = "zen-browser"
-- Noctalia: launcher e lock via IPC do Quickshell.
local launcher    = "qs -c noctalia-shell ipc call launcher toggle"
local lockscreen  = "qs -c noctalia-shell ipc call lockScreen toggle"
-- ⚠ Os nomes dos endpoints IPC (launcher / lockScreen / clipboard) podem variar
--   por versão do Noctalia. Se algum bind não responder, confira:
--   https://docs.noctalia.dev  →  Getting Started → Keybinds


-- ───────────── AUTOSTART ─────────────
-- Noctalia cobre barra, launcher, notificações, wallpaper, lock, idle e OSDs.
-- Por isso NÃO subimos mais waybar / rofi / mako / hyprpaper / hypridle.
hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c noctalia-shell")                  -- o shell inteiro
    hl.exec_cmd("hyprpolkitagent")                       -- auth gráfica (senha de apps)
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    -- hl.exec_cmd("nm-applet --indicator")  -- noctalia já tem widget de rede
end)


-- ───────────── APARÊNCIA / DECORAÇÃO / GERAL ─────────────
hl.config({
    general = {
        gaps_in  = 16,
        gaps_out = 20,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgb(6e6e6e)", "rgb(4a4a4a)" }, angle = 45 },
            inactive_border = "rgb(2e2e2e)",
        },
        layout = "dwindle",
        resize_on_border = true,
        allow_tearing    = false,
    },

    decoration = {
        rounding         = 8,
        active_opacity   = 1.0,
        inactive_opacity = 0.90,

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = 0xee0a0a0a,
        },

        blur = {
            enabled           = true,
            size              = 6,
            passes            = 2,
            new_optimizations = true,
            ignore_opacity    = true,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
        smart_split    = false,
        smart_resizing = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        focus_on_activate        = false,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    cursor = {
        inactive_timeout = 5,
    },

    input = {
        kb_layout  = "us",
        kb_variant = "intl",            -- US Intl. com dead keys
        kb_model   = "",
        kb_options = "compose:menu",    -- tecla Menu como Compose
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity  = 0,
    },
})


-- ───────────── CURVAS + ANIMAÇÕES ─────────────
hl.curve("smooth", { type = "bezier", points = { {0.25, 0.1}, {0.25, 1.0} } })
hl.curve("snappy", { type = "bezier", points = { {0.4,  0.0}, {0.2,  1.0} } })

hl.animation({ leaf = "windows",    enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "smooth", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 8, bezier = "smooth" })
hl.animation({ leaf = "fade",       enabled = true, speed = 5, bezier = "smooth" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "snappy", style = "slide" })


-- ───────────── REGRAS DE JANELA ─────────────
hl.window_rule({ name = "float-pavucontrol", match = { class = "^pavucontrol$" },          float = true })
hl.window_rule({ name = "size-pavucontrol",  match = { class = "^pavucontrol$" },          size  = "800 600" })
hl.window_rule({ name = "float-nm-editor",   match = { class = "^nm-connection-editor$" }, float = true })
hl.window_rule({ name = "float-blueman",     match = { class = "^blueman-manager$" },      float = true })
hl.window_rule({ name = "float-qt6ct",       match = { class = "^qt6ct$" },                float = true })

-- Apps GNOME comuns em flutuante (utilitários pequenos)
hl.window_rule({ name = "float-gnome-calc",  match = { class = "^org.gnome.Calculator$" }, float = true })
hl.window_rule({ name = "float-gnome-disks", match = { class = "^org.gnome.DiskUtility$" },float = true })

-- Picture-in-Picture (Zen/Firefox/Chrome)
hl.window_rule({ name = "pip-float", match = { title = "^Picture-in-Picture$" }, float = true, size = "480 270", pin = true })

-- Steam: tela cheia imediata (menos input lag, sem proteção de tearing)
hl.window_rule({ name = "steam-immediate",  match = { class = "^steam_app_" }, immediate = true })
hl.window_rule({ name = "steam-fullscreen", match = { class = "^steam_app_" }, fullscreen = true })


-- ───────────── WORKSPACES → MONITORES ─────────────
-- ws 1-3 no 4K (primário); ws 4-5 no vertical (comms/mídia).
hl.workspace_rule({ workspace = "1", monitor = "DP-1",     default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-1" })
hl.workspace_rule({ workspace = "3", monitor = "DP-1" })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1", default = true })
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-1" })


-- ───────────── APPS → WORKSPACES ─────────────
hl.window_rule({ name = "ws-alacritty", match = { class = "^Alacritty$" },             workspace = 1 })
hl.window_rule({ name = "ws-zen",       match = { class = "^zen$|^zen-browser$" },     workspace = 2 })
hl.window_rule({ name = "ws-zed",       match = { class = "^dev\\.zed\\.Zed$|^Zed$" }, workspace = 3 })
hl.window_rule({ name = "ws-discord",   match = { class = "^discord$" },               workspace = 4 })
hl.window_rule({ name = "ws-spotify",   match = { class = "^[Ss]potify$" },            workspace = 5 })
hl.window_rule({ name = "ws-obsidian",  match = { class = "^obsidian$" },              workspace = 3 })


-- ───────────── KEYBINDS ─────────────
local mainMod = "SUPER"

-- Aplicativos
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + Space",  hl.dsp.exec_cmd(launcher))                 -- noctalia launcher
hl.bind(mainMod .. " + V",      hl.dsp.exec_cmd("qs -c noctalia-shell ipc call clipboard toggle")) -- histórico (cliphist + noctalia)

-- Sessão
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("sh -c 'command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit'"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(lockscreen))                    -- noctalia lock

-- Janelas
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = 0 }))
hl.bind(mainMod .. " + C", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Foco com setas
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Trocar workspace com SUPER + ALT + setas
hl.bind(mainMod .. " + ALT + left",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.focus({ workspace = "e+1" }))

-- Mover janela com SHIFT + setas
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Redimensionar com CTRL + setas
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -20, y =   0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x =  20, y =   0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x =   0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x =   0, y =  20, relative = true }), { repeating = true })

-- Workspaces 1..10 + mover janela com SHIFT
for i = 1, 10 do
    local key = i % 10 -- 10 → 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad (especial) — em ` (grave)
hl.bind(mainMod .. " + grave",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:magic" }))

-- Mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Volume / mute (pipewire)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })

-- Brilho
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })

-- Mídia
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })

-- Screenshots (estilo Windows)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("sh -c 'grim -g \"$(slurp)\" - | wl-copy'"))
hl.bind("Print",                   hl.dsp.exec_cmd("sh -c 'grim - | wl-copy'"))
hl.bind(mainMod .. " + Print",     hl.dsp.exec_cmd("sh -c 'mkdir -p ~/Pictures && grim ~/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png'"))

# pyright: reportUnknownVariableType=false, reportUnknownArgumentType=false, reportUnknownMemberType=false, reportUnknownLambdaType=false, reportUnknownParameterType=false, reportUnknownVariableType=false, reportUntypedBaseClass=false, reportUntypedFunctionDecorator=false, reportUntypedClassDecorator=false
from __future__ import annotations

import argparse
import colorsys
import json
import os
import re
import subprocess
import tempfile
from typing import Any, Dict, List, Tuple


STATE_FILE = os.path.join(tempfile.gettempdir(), "glzr_wallpaper_theme_state.json")


def get_wallpaper_path() -> str:
    # 1. Wallpaper Engine active wallpaper
    we_config_paths = [
        os.path.expandvars(r"%ProgramFiles(x86)%\Steam\steamapps\common\wallpaper_engine\config.json"),
        os.path.expandvars(r"%ProgramFiles%\Steam\steamapps\common\wallpaper_engine\config.json"),
    ]
    for we_cfg in we_config_paths:
        if os.path.exists(we_cfg):
            try:
                with open(we_cfg, "r", encoding="utf-8", errors="ignore") as f:
                    data = json.load(f)

                for user_key, user_data in data.items():
                    if user_key.startswith("?") or not isinstance(user_data, dict):
                        continue
                    gen = user_data.get("general", {})
                    wp_cfg = gen.get("wallpaperconfig", {})
                    selected = wp_cfg.get("selectedwallpapers", {})
                    for _, item in selected.items():
                        if isinstance(item, dict) and "file" in item:
                            fpath = item["file"]
                            folder = os.path.dirname(fpath)
                            for preview in ["preview.jpg", "preview.png", "preview.gif", "preview.jpeg"]:
                                p_path = os.path.join(folder, preview)
                                if os.path.exists(p_path):
                                    return p_path
                            if os.path.exists(fpath) and fpath.lower().endswith((".jpg", ".png", ".jpeg", ".webp")):
                                return fpath
            except Exception:
                pass

    # 2. Windows TranscodedWallpaper
    transcoded = os.path.expandvars(r"%APPDATA%\Microsoft\Windows\Themes\TranscodedWallpaper")
    if os.path.exists(transcoded):
        return transcoded
    try:
        import winreg

        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Control Panel\Desktop")
        val, _ = winreg.QueryValueEx(key, "Wallpaper")
        if isinstance(val, str) and os.path.exists(val):
            return val
    except Exception:
        pass
    return r"C:\WINDOWS\web\wallpaper\Windows\img19.jpg"


def make_vibrant(hex_color: str, target_l: float = 0.65, target_s: float = 0.88) -> str:
    try:
        hex_str = hex_color.lstrip("#")
        r, g, b = tuple(int(hex_str[i : i + 2], 16) / 255.0 for i in (0, 2, 4))
        h, _, s = colorsys.rgb_to_hls(r, g, b)
        s = max(target_s, s * 1.35)
        s = min(0.96, s)
        cr, cg, cb = colorsys.hls_to_rgb(h, target_l, s)
        return f"#{int(cr*255):02x}{int(cg*255):02x}{int(cb*255):02x}"
    except Exception:
        return hex_color


def extract_image_clusters_magick(image_path: str) -> List[str]:
    try:
        res = subprocess.run(
            ["magick", image_path, "-scale", "64x64!", "-quantize", "HSL", "+dither", "-colors", "8", "-unique-colors", "txt:-"],
            capture_output=True,
            text=True,
            check=True,
        )
        hexes = re.findall(r"#[0-9A-Fa-f]{6}", res.stdout)
        if hexes:
            return list(dict.fromkeys(hexes))
    except Exception:
        pass
    return []


def get_theme_state() -> Dict[str, Any]:
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return {"offset": 0, "wallpaper": ""}


def save_theme_state(state: Dict[str, Any]) -> None:
    try:
        with open(STATE_FILE, "w", encoding="utf-8") as f:
            json.dump(state, f, indent=2)
    except Exception:
        pass


def extract_palette(image_path: str, reroll: bool = False) -> Dict[str, Any]:
    matugen_exe = os.path.expandvars(r"%USERPROFILE%\.cargo\bin\matugen.exe")
    executable = matugen_exe if os.path.exists(matugen_exe) else "matugen"
    cmd = [executable, "image", image_path, "--json", "hex", "--prefer", "saturation"]

    state = get_theme_state()
    last_wp = state.get("wallpaper", "")
    offset = state.get("offset", 0)

    if last_wp != image_path:
        offset = 0
    elif reroll:
        offset += 1

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        data: Dict[str, Any] = json.loads(result.stdout)
        colors: Dict[str, Any] = data.get("colors", {})
        palettes: Dict[str, Any] = data.get("palettes", {})

        def get_vibrant(pal_name: str, fallback_token: str, fallback_hex: str) -> str:
            pal = palettes.get(pal_name, {})
            for tone in ["60", "70", "50", "80", "40"]:
                if tone in pal and "color" in pal[tone]:
                    return pal[tone]["color"]
            return colors.get(fallback_token, {}).get("dark", {}).get("color") or fallback_hex

        primary_raw = get_vibrant("primary", "primary", "#00a8e8")
        clusters = extract_image_clusters_magick(image_path)

        candidate_colors: List[str] = [primary_raw]
        for hex_val in clusters[:6]:
            if hex_val not in candidate_colors:
                candidate_colors.append(hex_val)

        if len(candidate_colors) < 2:
            candidate_colors.append(get_vibrant("tertiary", "tertiary", "#f3b43f"))

        pairs: List[Tuple[str, str]] = []
        for i in range(len(candidate_colors)):
            for j in range(i + 1, len(candidate_colors)):
                c1 = make_vibrant(candidate_colors[i], target_l=0.64, target_s=0.92)
                c2 = make_vibrant(candidate_colors[j], target_l=0.68, target_s=0.92)
                if c1 != c2:
                    pairs.append((c1, c2))
                    pairs.append((c2, c1))

        if not pairs:
            pairs = [("#00a8e8", "#f3b43f"), ("#f3b43f", "#00a8e8")]

        current_pair = pairs[offset % len(pairs)]
        primary = current_pair[0]
        secondary = current_pair[1]

        save_theme_state({"offset": offset, "wallpaper": image_path})

        surface = colors.get("surface_container", {}).get("dark", {}).get("color") or "#1a1e22"
        surface_high = colors.get("surface_container_high", {}).get("dark", {}).get("color") or "#272e35"

        s_hex = surface.lstrip("#")
        s_r, s_g, s_b = tuple(int(s_hex[i : i + 2], 16) for i in (0, 2, 4))
        base_r = max(16, min(40, s_r))
        base_g = max(16, min(40, s_g))
        base_b = max(16, min(40, s_b))

        sh_hex = surface_high.lstrip("#")
        sh_r, sh_g, sh_b = tuple(int(sh_hex[i : i + 2], 16) for i in (0, 2, 4))
        surface0_r = max(26, min(56, sh_r))
        surface0_g = max(26, min(56, sh_g))
        surface0_b = max(26, min(56, sh_b))

        return {
            "base_rgb": f"{base_r}, {base_g}, {base_b}",
            "surface0_rgb": f"{surface0_r}, {surface0_g}, {surface0_b}",
            "primary": primary,
            "secondary": secondary,
            "variants": pairs,
            "offset": offset,
        }
    except Exception:
        return {
            "base_rgb": "24, 26, 36",
            "surface0_rgb": "36, 40, 54",
            "primary": "#00a8e8",
            "secondary": "#f3b43f",
            "variants": [("#00a8e8", "#f3b43f"), ("#f3b43f", "#00a8e8")],
            "offset": 0,
        }


def generate_theme_files(palette: Dict[str, Any]) -> None:
    islands_colors = f"""/* Dynamic Wallpaper-Synced True Duo-Tone Theme */
:root {{
  /* Clean Semantic Duo-Tone Tokens */
  --theme-accent-primary: {palette['primary']};
  --theme-accent-secondary: {palette['secondary']};
  --theme-bg-island: rgba({palette['base_rgb']}, 0.85);
  --theme-bg-notch: rgb({palette['base_rgb']});
  --theme-surface: rgba({palette['surface0_rgb']}, 0.85);
  --theme-text: #cdd6f4;
  --theme-text-muted: rgba(205, 214, 244, 0.65);
}}
"""
    palette_json_content = json.dumps(
        {
            "current": {
                "primary": palette["primary"],
                "secondary": palette["secondary"],
                "base_rgb": palette["base_rgb"],
                "surface0_rgb": palette["surface0_rgb"],
            },
            "variants": palette["variants"],
            "offset": palette.get("offset", 0),
        },
        indent=2,
    )

    live_target = os.path.expandvars(r"%USERPROFILE%\.glzr\zebar\theme-islands")
    if os.path.exists(live_target):
        with open(os.path.join(live_target, "colors.css"), "w", encoding="utf-8") as f:
            f.write(islands_colors)
        with open(os.path.join(live_target, "palette.json"), "w", encoding="utf-8") as f:
            f.write(palette_json_content)


def sync_glazewm_border(primary_hex: str) -> None:
    targets = [
        os.path.expandvars(r"%USERPROFILE%\.glzr\glazewm\config.yaml"),
        os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "glazewm", "config.yaml")),
    ]
    for live_yaml in targets:
        if not os.path.exists(live_yaml):
            continue
        with open(live_yaml, "r", encoding="utf-8") as f:
            lines = f.readlines()

        new_lines: list[str] = []
        in_focused_window = False
        in_border = False

        for line in lines:
            if "focused_window:" in line:
                in_focused_window = True
            elif in_focused_window and "other_windows:" in line:
                in_focused_window = False
                in_border = False

            if in_focused_window:
                if "border:" in line:
                    in_border = True
                elif in_border and "color:" in line:
                    line = re.sub(r"color:\s*['\"].*?['\"]", f"color: '{primary_hex}'", line)
                    in_border = False

            new_lines.append(line)

        new_content = "".join(new_lines)
        with open(live_yaml, "w", encoding="utf-8") as f:
            f.write(new_content)

    # Hot-reload GlazeWM so new border takes effect immediately
    try:
        subprocess.run(["glazewm", "command", "wm-reload-config"], capture_output=True, check=False)
    except Exception:
        pass


def main() -> None:
    parser = argparse.ArgumentParser(description="Wallpaper theme sync & reroll")
    parser.add_argument("--reroll", action="store_true", help="Reroll color variations from current wallpaper")
    args = parser.parse_args()

    wp = get_wallpaper_path()
    print(f"Reading wallpaper: {wp}")

    palette = extract_palette(wp, reroll=args.reroll)
    generate_theme_files(palette)
    sync_glazewm_border(palette["primary"])
    print(f"Theme sync complete (Primary={palette['primary']}, Secondary={palette['secondary']})")


if __name__ == "__main__":
    main()

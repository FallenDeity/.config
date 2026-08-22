from __future__ import annotations

import json
import os
import re
import subprocess
from typing import Any, Dict, Optional


def get_wallpaper_path() -> str:
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


def get_default_palette() -> Dict[str, str]:
    return {
        "base_rgb": "30, 30, 46",
        "primary": "#fab387",
        "secondary": "#74c7ec",
        "tertiary": "#cba6f7",
        "peach": "#fab387",
        "sapphire": "#74c7ec",
        "mauve": "#cba6f7",
        "green": "#a6e3a1",
        "yellow": "#f9e2af",
        "pink": "#f38ba8",
    }


def extract_palette_matugen(image_path: str) -> Dict[str, str]:
    matugen_exe = os.path.expandvars(r"%USERPROFILE%\.cargo\bin\matugen.exe")
    executable = matugen_exe if os.path.exists(matugen_exe) else "matugen"
    cmd = [executable, "image", image_path, "--json", "hex", "--prefer", "saturation"]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        data: Dict[str, Any] = json.loads(result.stdout)
        colors: Dict[str, Any] = data.get("colors", {})

        def get_color(token_name: str, fallback: str) -> str:
            token: Dict[str, Any] = colors.get(token_name, {})
            dark_color: Optional[str] = token.get("dark", {}).get("color")
            default_color: Optional[str] = token.get("default", {}).get("color")
            return dark_color or default_color or fallback

        primary = get_color("primary", "#fab387")
        secondary = get_color("secondary", "#74c7ec")
        tertiary = get_color("tertiary", "#cba6f7")
        surface = get_color("surface_container_high", "#22232a")

        surface_hex = surface.lstrip("#")
        s_r, s_g, s_b = tuple(int(surface_hex[i : i + 2], 16) for i in (0, 2, 4))
        base_r = max(28, min(50, int(s_r * 1.1)))
        base_g = max(28, min(50, int(s_g * 1.1)))
        base_b = max(38, min(68, int(s_b * 1.1)))

        print("Extracted palette using Matugen (Material You 3 Scheme).")
        return {
            "base_rgb": f"{base_r}, {base_g}, {base_b}",
            "primary": primary,
            "secondary": secondary,
            "tertiary": tertiary,
            "peach": primary,
            "sapphire": secondary,
            "mauve": tertiary,
            "green": "#a6e3a1",
            "yellow": "#f9e2af",
            "pink": "#f38ba8",
        }
    except Exception as e:
        print(f"Matugen unavailable ({e}); using default Catppuccin palette.")
        return get_default_palette()


def generate_theme_files(config_root: str, palette: Dict[str, str]) -> None:
    islands_colors = f"""/* Dynamic Matugen Wallpaper Palette */
:root {{
  --mocha-base: rgba(30, 30, 46, 0.85);
  --mocha-notch: rgb({palette['base_rgb']});
  --mocha-surface0: rgba(49, 50, 68, 0.85);
  --mocha-peach: {palette['primary']};
  --mocha-sapphire: {palette['secondary']};
  --mocha-mauve: {palette['tertiary']};
  --mocha-green: {palette['green']};
  --mocha-yellow: {palette['yellow']};
  --mocha-red: {palette['pink']};
}}
"""
    islands_dir = os.path.join(config_root, "zebar", "theme-islands")
    if os.path.exists(islands_dir):
        with open(os.path.join(islands_dir, "colors.css"), "w", encoding="utf-8") as f:
            f.write(islands_colors)

    print("Generated dynamic colors.css for active themes.")


def sync_glazewm_border(config_root: str, primary_hex: str) -> None:
    yaml_path = os.path.join(config_root, "glazewm", "config.yaml")
    if not os.path.exists(yaml_path):
        return

    with open(yaml_path, "r", encoding="utf-8") as f:
        content = f.read()

    new_content = re.sub(
        r"(focused_border_color:\s*['\"]).*?(['\"])",
        rf"\g<1>{primary_hex}\g<2>",
        content,
    )
    if new_content != content:
        with open(yaml_path, "w", encoding="utf-8") as f:
            f.write(new_content)
        print(f"Updated GlazeWM focused border color to {primary_hex}")


def main() -> None:
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    wp = get_wallpaper_path()
    print(f"Reading wallpaper: {wp}")

    palette = extract_palette_matugen(wp)
    print(f"Palette extracted: Primary={palette['primary']}, Secondary={palette['secondary']}")
    generate_theme_files(repo_root, palette)
    sync_glazewm_border(repo_root, palette["primary"])


if __name__ == "__main__":
    main()

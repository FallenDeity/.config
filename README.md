# Dotfiles for Windows

Here in lies my dotfiles for windows and bunch of put together powershell scripts to sync everything and throw them in all different places expected by different tools

## Screenshots

| <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/5fc194bc-ab42-43f8-a846-5dc23332e6f5" /> | <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/8d6ab98e-1332-49d0-85e6-22d97e759b5a" /> |
| - | - |
| <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/24595de2-0b07-473d-a88c-24cf3362a5e5" /> | <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/d35cafaa-71b3-449c-8cba-504e7b1b2d4b" /> |
| - | - |
| <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/2007f4e5-859f-456e-93af-68893dd76cfb" /> | <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/15ebd5be-a2cb-446f-a4b3-5d15602f4a00" /> |
| - | - |
| <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/704d2640-cd06-4a6a-b4fe-e7d3a4fa7c08" /> | <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/ddd2fa6b-ff12-4613-98f5-db3f352c20cf" />

## Installation

Clone this repository into your `.config` directory inside `C:\Users\<user>` and just run `setup.ps1` that's it, it will take care of everything else.

```pwsh
$ git clone https://github.com/FallenDeity/.config
$ cd .config
$ .\setup.ps1
```
Some specific stuff like windhawk and wallpaper engine require manual setup, windhawk ones are documented in the readme relevant to the directory. For wallpaper feel free to use any wall paper zebar and glazewm shall sync with the wallpaper set. An added benefit of the engine is it sets the windows accent color too, but that can be easily enabled in windows:

- Go to Settings > Personalization > Colors.
- Under Accent color, change the dropdown from Manual to Automatic.



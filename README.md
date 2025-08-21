### Termux MOTD

A modern, colorful, and information-rich Message of the Day (MOTD) script for Termux.
This script displays system information (storage, memory, swap, battery) in a visually appealing format with Unicode level indicators and adaptive colors.

─────⋆⋅☆⋅⋆─────

Some devices have a delayed output for the current.
If you recently plugged/unplugged the power, the current (shown in mA) might take a few seconds to register.

─────⋆⋅☆⋅⋆─────

#### ✨ Features

📦 **Storage info** – Shows internal storage and the system partition (if root is available).

📊 **Memory usage** – Uses `MemAvailable` when present; handles Android 9 and earlier quirks correctly by automatically falling back to a calculated value.

📜 **Swap stats** – Displays swap totals, free space, and cached swap usage.

🔋 **Battery details** – Includes percentage, charging current, health, and temperature.

🎨 **Adaptive color scheme** – Detects Termux’s background (dark vs. light) for optimal readability.

📈 **Unicode level indicators** – Thresholds for yellow/red warnings on storage, memory, and battery configurable at the top of the script.

⚡ **Lightweight** – Runs at Termux startup with no external dependencies beyond Termux:API.

─────⋆⋅☆⋅⋆─────

#### 📸 Example output
```
⟦ 𝑻𝒆𝒓𝒎𝒖𝒙 ⟧

💾 Internal storage: 9.7 GB free
⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬜⬜⬜⬜ 62%
Used: 16.2 GB ∕ 25.8 GB

📦 System partition: 748.3 MB free
⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬜⬜⬜⬜ 62%
Used: 1.2 GB ∕ 1.9 GB

📊 Memory: 528.1 MB free
🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥⬜⬜⬜ 82%
Used: 2.4 GB ∕ 2.9 GB
Buffers = 7.6 MB
Cached = 404.7 MB

📜 Swap: 0 kB free
🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥 100%
Used: 512 MB ∕ 512 MB
Cached = 2.1 MB

🔋 Battery status: Good
⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬜⬜⬜ 80%
Unplugged: 225.5 mA
28.2° (82.8°F)
```

─────⋆⋅☆⋅⋆─────

#### 📥 Installation

1. **Install Termux:API** (If you haven't already):

Download the [Termux:API](https://f-droid.org/en/packages/com.termux.api/) from F-Droid.

Install the termux-api package from Termux's package manager:
```
pkg up
pkg in termux-api -y
```

2. **Download the script**:

Download [motd.sh](https://raw.githubusercontent.com/xioru0v68tttj/Termux-motd/main/motd.sh) and save it to ~/.termux .

Or,

```
cd ~/.termux
curl -O https://raw.githubusercontent.com/xioru0v68tttj/Termux-motd/main/motd.sh
```

On next login, the MOTD will display automatically.

─────⋆⋅☆⋅⋆─────

#### ⚙️ Configuration

At the top of `motd.sh`, you can configure level indicator color thresholds and size:

```bash
# User-configurable level indicator color-threshold formulas (Android 10+):
STORAGE_YELLOW='(( $free < 5242880 ))'   < 5 GB free (warning)
STORAGE_RED='(( $free < 1048576 ))'      < 1 GB free (danger)
MEMORY_YELLOW='(( $pct >= 50 ))'
MEMORY_RED='(( $pct > 70 ))'
BATTERY_YELLOW='(( ${battery[percentage]} < 30 ))'
BATTERY_RED='(( ${battery[percentage]} < 10 ))'

# User-configurable level indicator size
GRAPH_SIZE=14
```

You can also change the colors by editing the script.
```
# Set colors
if (( $use_dark_text )); then
	loading_c="6;76;137"			# Dark Slate Blue
	error_c="197;39;39"				# Fire Engine Red
	cmd_c="80;116;116"					# Sophisticated Teal
	text_c="127;127;127"			# Dark Gray
	code_c="80;116;116"				# Sophisticated Teal
	primary_c="72;24;80"			# American Purple
	hilight_c="25;95;221"			# Navy Blue
else
	loading_c="248;205;245" 	# Jacaranda
	error_c="255;114;111"			# Salmon
	cmd_c="255;248;255"				# Lovely Euphoric Delight
	text_c="140;156;164"			# Lakefront
	code_c="118;193;186"			# Cadet Blue
	primary_c="156;141;219"		# Middy's Purple
	hilight_c="0;255;255"			# Cyan
fi
```
─────⋆⋅☆⋅⋆─────

#### 📜 License

[The Unlicense](https://unlicense.org)

This is free and unencumbered software released into the public domain.
Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

─────⋆⋅☆⋅⋆─────

Logo

Bonus

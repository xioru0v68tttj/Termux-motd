#!/data/data/com.termux/files/usr/bin/bash

# ⊰⚋☆⚋⊱ Project Lachesis: motd⨧ ⊰⚋☆⚋⊱

# ~/.termux/motd.sh
# this file is called by $PREFIX/bin/login

# User-configurable level indicator color-threshold formulas (Android 10+):
STORAGE_YELLOW='(( $free < 5242880 ))'
STORAGE_RED='(( $free < 1048576 ))'
MEMORY_YELLOW='(( $pct >= 50 ))'
MEMORY_RED='(( $pct > 70 ))'
BATTERY_YELLOW='(( ${battery[percentage]} < 30 ))'
BATTERY_RED='(( ${battery[percentage]} < 10 ))'

# User-configurable level indicator size
GRAPH_SIZE=14

# Read background color
background_color=$(grep '^background=' "$HOME/.termux/colors.properties" | cut -d'#' -f2)
background_color=${background_color:-000000}

# Convert hex to RGB and calculate brightness
if [ -n "$background_color" ] && [ ${#background_color} -eq 6 ]; then
	# Extract RGB components
	r=$(printf "%d" 0x${background_color:0:2})
	g=$(printf "%d" 0x${background_color:2:2})
	b=$(printf "%d" 0x${background_color:4:2})
	
	# Simple brightness calculation
	brightness=$(( (r*299+g*587+b*114)/1000 ))
	
	# Store true if background is light (use dark text), false if background is dark (use light text)
	if [ $brightness -ge 128 ]; then
		use_dark_text=1  # Light background → use dark text
	else
		use_dark_text=0 # Dark background → use light text
	fi
else
	use_dark_text=0 # Default to light text for black background
fi

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

# Cleanse color codes
for c in loading error cmd text code primary hilight; do
	eval "${c}_color=\"\033[38;2;\${${c}_c}m\""
done

# Check if termux-api is available
if ! command -v termux-battery-status >/dev/null; then
	echo -e "${error_color}Error"
	echo -e "${cmd_color}Termux:API${text_color} is not installed."
	echo -e "Install it from F-Droid and run:"
	echo -e "${code_color}  pkg up && pkg in termux-api -y"
	echo
	echo -e "${text_color}If you do not wish to install it,\nsimply delete this script.\033[0m"
	exit 1
fi

# Show loading message
echo -ne "${loading_color}Loading…\033[0m"

# Set up graph colors
colors=(black white red blue orange yellow green purple brown)

# Contrast graph against background
if (( !use_dark_text )); then
	# Detect Android version and set character set
	android_version=$(getprop ro.build.version.release | cut -d. -f1)
	if (( android_version >= 10 )); then
		chars=(⬛ ⬜ 🟥 🟦 🟧 🟨 🟩 🟪 🟫)
	else
		chars=(⬛ ⬜ ⬜ ⬜ ⬜ ⬜ ⬜ ⬜ ⬜)
	fi
else # dark backbround=light text
	if (( android_version >= 10 )); then
		chars=(⬜ ⬛ 🟥 🟦 🟧 🟨 🟩 🟪 🟫)
	else
		chars=(⬜ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛ ⬛)
	fi
fi

declare -A square
for i in "${!colors[@]}"; do
	square["${colors[i]}"]="${chars[i]}"
done

# Engineering notation
bytes=(kB MB GB TB)
amps=(μA mA A)

# Terminal width
read -r screen_rows screen_width < <(stty size)

# Round to integer
# Specify significant digits (only affects fractional portion) as second parameter
Round() {
	local num=$1 digits=$2 dp value

	[[ -z "$num" ]] && return

	# Set decimal places
	if [[ -z "$digits" ]]; then
		dp=0
	else
		dp=$((digits - 1))
		(( dp < 0 )) && dp=0
	fi

	# Do the rounding
	printf -v value "%.*f" "$dp" "$num"

	# Remove trailing zeros
	while [[ "$value" == *0 ]] && [[ "$value" == *.* ]]; do
		value="${value%0}"
	done

	# Remove trailing dot
	value="${value%.}"

	echo "$value"
}

Format() {
	local num=$1
	local -n _arr=$2
	local -a suffixes=("${_arr[@]}")
	local -i suffix=0

	# Use awk for comparison and division to preserve decimals
	while awk "BEGIN {exit !($num >= 1024)}"; do
		num=$(awk "BEGIN {print $num/1024}")
		((suffix++))
		[ $suffix -ge $((${#suffixes[@]} - 1)) ] && break
	done

	echo "$(Round "$num" 2) ${suffixes[suffix]}"
}

Graph() {
	local pct=$1
	local yellow=$2
	local red=$3
	local size=$GRAPH_SIZE
	local empty=${square[black]}
	local block=${square[white]}
	
	# Evaluate color conditions
	if eval "$yellow"; then
		block=${square[yellow]}
	fi
	if eval "$red"; then
		block=${square[red]}
	fi
	
	# Calculate filled portion (rounded)
	local filled=$(Round $(bc -l <<<"($pct*$size)/100"))
	
	# Build output
	local output=""
	for ((i=0;i<filled;i++)); do
		output+="$block"
	done
	for ((i=filled;i<size;i++)); do
		output+="$empty"
	done
	
	echo $output
}

Storage() {
	local name=$1
	local cmd=$2

	read -r free used <<< $(eval "$cmd" | awk 'NR==2 {print $4, $3}')
	local total=$((free + used))
	(( total==0 )) && total=1
	local pct=$((used * 100 / total))

	output+="${primary_color}${name}: ${hilight_color}$(Format $free bytes)${primary_color} free\n"
	output+="$(Graph $pct "$STORAGE_YELLOW" "$STORAGE_RED")"
	output+=" ${hilight_color}$(Round $pct 2)%\n"
	output+="${primary_color}Used: ${hilight_color}$(Format $used bytes)${primary_color} ∕ ${hilight_color}$(Format $total bytes)\n\n"
}

Memory() {
	local name=$1
	local total_key=$2
	local free_key=$3
	shift 3
	local -a extras=("$@")

	# Read from /proc/meminfo
	declare -A meminfo
	while IFS=': ' read -r key value _; do
		meminfo[$key]=$value
	done < /proc/meminfo

	local total=${meminfo[$total_key]}
	local free=${meminfo[$free_key]}

	# Fix for Android 9 and earlier: calculate MemAvailable if missing
	if [[ "$free_key" == "MemAvailable" && -z "$free" ]]; then
		free=$(( ${meminfo[MemFree]:-0} + ${meminfo[Buffers]:-0} + ${meminfo[Cached]:-0} ))
	fi
	
	local used=$((total - free))
	(( total == 0 )) && total=1
	local pct=$((used * 100 / total))

	output+="${primary_color}${name}: ${hilight_color}$(Format $free bytes)${primary_color} free\n"
	output+="$(Graph $pct "$MEMORY_YELLOW" "$MEMORY_RED")"
	output+=" ${hilight_color}$(Round $pct 2)%\n"
	output+="${primary_color}Used: ${hilight_color}$(Format $used bytes)${primary_color} ∕ ${hilight_color}$(Format $total bytes)\n"

	for field in "${extras[@]}"; do
		local heading key
		if [[ "$field" == *=* ]]; then
			heading="${field%%=*}"
			key="${field#*=}"
		else
			heading="$field"
			key="$field"
		fi
		output+="${primary_color}${heading} = ${hilight_color}$(Format "${meminfo[$key]}" bytes)\n"
	done

	output+="\n"
}

Battery() {
	local name=$1
	local status_key

# Load battery stats into memory
declare -A battery
while IFS= read -r line; do
	# Match lines with "key": value (ignore {, }, and trailing commas)
	if [[ $line =~ ^[[:space:]]*\"([^\"]+)\"[[:space:]]*:[[:space:]]*(\"?[^\"]*\"?)[[:space:]]*,?$ ]]; then
	
		key="${BASH_REMATCH[1]}"
		value="${BASH_REMATCH[2]}"
		# Remove surrounding quotes from value if present
		value="${value%\"}"
		value="${value#\"}"
		value="${value%,}"	# remove trailing comma		
		battery["$key"]="$value"
	fi
done < <(termux-battery-status)

	[[ "${battery[status]}" == "CHARGING" ]] && status_key="${battery[status]}" || status_key="${battery[plugged]}"
	status_key=${status_key,,}
	status_key=${status_key^}
	status_current=${battery[current]}
	status_current=${status_current#-}

	battery_health=${battery[health]}
	battery_health=${battery_health,,}
	output+="${primary_color}${name}: ${hilight_color}${battery_health^}\n"
	output+="$(Graph ${battery[percentage]} "$BATTERY_YELLOW" "$BATTERY_RED")"
	output+=" ${hilight_color}${battery[percentage]}%\n"
	output+="${primary_color}$(tr '[:upper:]' '[:lower:]' <<< ${status_key:0:1} | tr '[:lower:]' '[:upper:]')${status_key:1}: "
	output+="${hilight_color}$(Format ${status_current} amps)\n"
	output+="${battery[temperature]}°"
	output+="${primary_color} ("
	output+="${hilight_color}$(Round "$(awk "BEGIN {print ${battery[temperature]}*9/5+32}")" 2)°F"
	output+="${primary_color})"
}

# ------------------- output -------------------
# Initialize output buffer
output="\033[1G\033[K${primary_color}⟦${hilight_color} 𝑻𝒆𝒓𝒎𝒖𝒙 ${primary_color}⟧\n\n"

# Display internal storage info
Storage "💾 Internal storage" "df -k /sdcard"

# Display system partition if root is available
if { command -v su >/dev/null 2>&1 && su -c true >/dev/null 2>&1; }; then
	Storage "📦 System partition" "su -c 'df -k /system'"
fi

# Display RAM info
Memory "📊 Memory" "MemTotal" "MemAvailable" "Buffers" "Cached=Cached"

# Display swap info
Memory "📜 Swap" "SwapTotal" "SwapFree" "Cached=SwapCached"

# Display battery info
Battery "🔋 Battery status"

echo -e "$output\n"








#
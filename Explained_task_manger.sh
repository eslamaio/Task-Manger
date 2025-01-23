#!/bin/bash   # tells the system to execute the script using the Bash shell.

# Task Manager with Rofi and Dmenu
# Uses rofi for a graphical menu, with dmenu as a fallback.
# Displays icons and emojis for a better user experience.
# Features:
# - File navigation, search, and bookmark management
# - View recent files and manage favorites
# - System management: processes, RAM, disk usage
# - Network traffic monitoring with Wireshark
# - Volume control and Wi-Fi management
# - System power options: shutdown, reboot, suspend

#  Function to display a menu using rofi (if available) or dmenu (fallback)
show_menu() {
    if command -v rofi &>/dev/null; then                # Check if rofi is installed
        echo -e "$1" | rofi -dmenu -p "📌 Task Manager" # Show menu with rofi         
    else
        echo -e "$1" | dmenu -p "📌 Task Manager"       # Show menu with dmenu if rofi is not installed
    fi
}

# command -v rofi

#The command utility is a built-in Bash command used to locate and determine if a given command (e.g., rofi) exists and is executable.
#-v tells command to print the full path of the command (rofi) if it exists, or return nothing if it doesn’t.
#&>/dev/null
#&> redirects both stdout (standard output) and stderr (error output) to /dev/null, which is a special null device that discards all input.
#This prevents unnecessary messages from appearing in the terminal.
#Alternative Ways to Check for a Command
#$ if which rofi &>/dev/null; then echo "Rofi is installed"; fi
#$ if hash rofi 2>/dev/null; then echo "Rofi is installed"; fi
#$ if type rofi &>/dev/null; then echo "Rofi is installed"; fi

# Define Menu Options with Emojis for better UX
OPTIONS="📂 File Manager\n🔍 Search Files\n📑 Manage Bookmarks\n📂 Recent Files\n⭐ Favorites\n🖥️ System Management\n📡 Network Traffic\n🔊 Volume Control\n📶 Wi-Fi Management\n🔋 System Power\n❌ Quit"

#This defines a string containing the menu options.
#Each option is separated by \n (newline) so that they appear as separate menu items when displayed.
#Emojis enhance the user experience (UX) by making the menu more visually appealing and easier to understand.

# Display the menu and capture user selection
#Calls show_menu function to display the menu and stores the selected option in CHOICE
CHOICE=$(show_menu "$OPTIONS")

# Calls the show_menu function, which:
# Uses rofi (if available) for a graphical interface.
# Falls back to dmenu if rofi is not installed.
# Stores the user’s selected option in CHOICE, which is used later to determine what action to take.

# Execute actions based on user's choice
#Uses a case statement to execute the appropriate command based on the user’s selection.
# The case statement is used to match the user's choice ($CHOICE) against predefined options.
# It functions like a switch-case in other programming languages
case "$CHOICE" in
    "📂 File Manager")
        # Open the file manager in the home directory
		# xdg-open is a cross-platform command that opens files and directories with the default application.
		# The ~ symbol represents the current user's home directory (/home/username on Linux).
		#;; Ends the case block for "📂 File Manager", allowing the script to continue checking other cases.
        xdg-open ~
        ;;
    "🔍 Search Files")
        # Prompt user for a filename to search
		# Calls show_menu with the prompt "Enter filename to search:".
		# Displays a small input box where the user can type the filename they want to search for.
		# Stores the user's input in the variable SEARCH_TERM.
        SEARCH_TERM=$(show_menu "Enter filename to search:")
        # Use `find` command to search for files and display results
		# find ~ -name "*$SEARCH_TERM*"
		# Searches for files in the home directory (~).
		# -name "*$SEARCH_TERM*":
		# Matches any file containing $SEARCH_TERM in its name.
		# Modify find to be case-insensitive (-iname)
		# The * wildcard ensures partial matches.
		# 2>/dev/null
		# Suppresses error messages (e.g., "Permission denied" errors).
		# | show_menu
		# Pipes (|) the search results into show_menu.
		# The user can select a file from the results.
        #find ~ -iname "*$SEARCH_TERM*" 2>/dev/null | show_menu
		# Modify the script to open the selected file:
		# After searching, the script will open the selected file using the default application.
		SELECTED_FILE=$(find ~ -name "*$SEARCH_TERM*" 2>/dev/null | show_menu)
		[[ -n "$SELECTED_FILE" ]] && xdg-open "$SELECTED_FILE"
		# [[ -n "$SELECTED_FILE" ]]
		# This checks if the variable SELECTED_FILE is non-empty.
		# -n is a string test operator that returns true if the string is not empty.
		# && (Logical AND Operator)
		# Ensures that xdg-open is only executed if the condition is true.
		# If SELECTED_FILE is empty, xdg-open will not run.
		# xdg-open "$SELECTED_FILE"
		# Opens the file using the default application.
		# Works on Linux and automatically selects the correct application.
        ;;
    "📑 Manage Bookmarks")
        # File to store bookmarks
		# Defines the file where bookmarks are saved.
		# The file is stored in the user's home directory as .bookmarks (hidden file).
		# [[ ! -f "$BOOKMARKS_FILE" ]]:
		# Checks if the bookmarks file does NOT exist.
		# && touch "$BOOKMARKS_FILE":
		# If the file does not exist, it creates an empty file.		
        BOOKMARKS_FILE="$HOME/.bookmarks"
        [[ ! -f "$BOOKMARKS_FILE" ]] && touch "$BOOKMARKS_FILE"
        
		# Calls show_menu to display options for managing bookmarks.
		# Stores the user's selection in the variable ACTION.
        # Display Bookmark Management Menu
		# Processes the user's choice (ACTION) from the bookmark menu.
        ACTION=$(show_menu "📌 Bookmarks\n➕ Add\n➖ Remove\n📜 View")
        case "$ACTION" in
            "➕ Add")
                # Prompt user for directory path and save to bookmarks file
				# Prompts the user to enter a directory path.
				# Stores the user input in DIR.
				# Appends the directory to the bookmarks file (~/.bookmarks).
                DIR=$(show_menu "Enter directory path:")
                echo "$DIR" >> "$BOOKMARKS_FILE"
                ;;
            "➖ Remove")
                # Let user select a bookmark to remove
				# Displays all saved bookmarks using cat "$BOOKMARKS_FILE" | show_menu.
				# The user selects a bookmark to remove.
				# sed -i "\|$TO_REMOVE|d" "$BOOKMARKS_FILE":
				# Deletes the selected bookmark from ~/.bookmarks.
				# The \| delimiter ensures that special characters in paths do not cause issues.
				# sed (Stream Editor) is a powerful command-line tool used to process and modify text in files.
				# It can search, replace, delete, or modify lines
				# "|$TO_REMOVE|" (Delimiters for Matching)
				# This is the pattern to match in the file.
				# Normally, / is used as a delimiter in sed, but since file paths may contain /, we use | instead.				
                TO_REMOVE=$(cat "$BOOKMARKS_FILE" | show_menu)
                sed -i "\|$TO_REMOVE|d" "$BOOKMARKS_FILE"
                ;;
            "📜 View")
                # Display bookmarks
				# Displays all saved bookmarks using cat "$BOOKMARKS_FILE".
				# Uses show_menu to display the list in rofi/dmenu.
                cat "$BOOKMARKS_FILE" | show_menu
                ;;
        esac
        ;;
    "📂 Recent Files")
        # Find and display recently modified files (last 10)
		# This is a pipelines of commands that:
		# Finds recently modified files.
		# Sorts them in descending order (newest first).
		# Selects the latest 10 files.
		# Formats and displays them in a menu.
		# find ~ → Search in the home directory (~).
		# -type f → Only include files (not directories).
		# -printf "%T+ %p\n" → Customize output format:
		# %T+ → Prints the last modification time in YYYY-MM-DD+HH:MM:SS format.
		# %p → Prints the full file path.
		# \n → Ensures each result is on a new line.
		# sort -r (Sort in Reverse Order)
		# Sorts the output in descending order (newest files first).
		# -r → Reverse sort order.
		# head -10 (Select Only 10 Files)
		# Extracts only the first 10 lines (the 10 most recently modified files).
		# If there are fewer than 10 files, it displays all available files.
		# cut -d' ' -f2- (Remove Timestamps)
		# Removes the timestamps, keeping only the file paths.
		# -d' ' → Uses space as a delimiter.
		# -f2- → Selects everything after the first space (i.e., the file path).
        find ~ -type f -printf "%T+ %p\n" | sort -r | head -10 | cut -d' ' -f2- | show_menu
        ;;
    "⭐ Favorites")
		# allows users to manage favorite files by adding, removing, and viewing saved favorites. 
        # File to store favorite files
		# Defines the file where favorite files are saved.
		# Stored in the home directory (~) as .favorites (hidden file).	
		# [[ ! -f "$FAVORITES_FILE" ]]:
		# Checks if the favorites file does NOT exist.
		# && touch "$FAVORITES_FILE":
		# If the file does not exist, creates an empty file.
        FAVORITES_FILE="$HOME/.favorites"
        [[ ! -f "$FAVORITES_FILE" ]] && touch "$FAVORITES_FILE"
        
        # Display Favorite Management Menu
		# Calls show_menu to display options for managing favorites.
		# Stores the user's selection in the variable ACTION.
        ACTION=$(show_menu "⭐ Favorites\n➕ Add\n➖ Remove\n📜 View")
        case "$ACTION" in
            "➕ Add")
                # Prompt user for file path to add to favorites
				# Prompts the user to enter a file path.
				# Stores the user input in FILE.
				# Appends the file path to the favorites file (~/.favorites).
                FILE=$(show_menu "Enter file path:")
                echo "$FILE" >> "$FAVORITES_FILE"
                ;;
            "➖ Remove")
                # Let user select a favorite to remove
				# Displays all saved favorites using cat "$FAVORITES_FILE" | show_menu.
				# The user selects a favorite to remove.
				# sed -i "\|$TO_REMOVE|d" "$FAVORITES_FILE":
				# Deletes the selected favorite from ~/.favorites.
				# The \| delimiter ensures that special characters in file paths do not cause issues.
                TO_REMOVE=$(cat "$FAVORITES_FILE" | show_menu)
                sed -i "\|$TO_REMOVE|d" "$FAVORITES_FILE"
                ;;
            "📜 View")
                # Display favorite files
				# Displays all saved favorite files using cat "$FAVORITES_FILE".
				# Uses show_menu to display the list in rofi/dmenu.			
                cat "$FAVORITES_FILE" | show_menu
                ;;
        esac
        ;;
	# This section of the script provides a system management menu, allowing users to view:
	# System Information (neofetch)
	# Running Processes (ps -ef)
	# Disk Usage (df -h)
	# RAM Usage (free -h)
    "🖥️ System Management")
        # Sub-menu for system-related tasks
		# Defines system options as a newline-separated list (\n).
		# Displays the menu using show_menu.
		# Stores the user's selection in SYS_CHOICE.
        SYSTEM_OPTIONS="🛠️ System Info\n📌 Running Processes\n💽 Disk Usage\n🚀 RAM Usage"
        SYS_CHOICE=$(show_menu "$SYSTEM_OPTIONS")
        case "$SYS_CHOICE" in
            "🛠️ System Info")
                # Display system information using `neofetch`
				# Runs neofetch, a command-line tool that displays system information.
				# Pipes (|) the output to show_menu, so the user can view it in rofi/dmenu
				# OS: Ubuntu 22.04 LTS
				# Kernel: 5.15.0-79-generic
				# Uptime: 3 days, 4 hours
				# Packages: 2203
				# Shell: Bash 5.1.16
				# CPU: Intel i7-10750H @ 2.60GHz
				# Memory: 8GB / 16GB
				# GPU: NVIDIA GTX 1650
                neofetch | show_menu
                ;;
            "📌 Running Processes")
                # Show running processes
				# Runs ps -ef, which lists all running processes.
				# Displays the output in rofi/dmenu.
				# UID   PID  PPID  CMD
				# root   1     0   /sbin/init
				# user  105   101  /usr/bin/gnome-shell
				# user  312   105  /usr/lib/firefox/firefox
                ps -ef | show_menu
                ;;
            "💽 Disk Usage")
                # Display disk usage
				# Runs df -h, which shows disk space usage in a human-readable format (-h).
				# Displays the output in rofi/dmenu.
				# Filesystem      Size  Used Avail Use% Mounted on
				# /dev/sda1      500G  200G  300G  40%  /
				# /dev/sdb1      1TB   500G  500G  50%  /mnt/data
                df -h | show_menu
                ;;
            "🚀 RAM Usage")
                # Display RAM usage
				# Runs free -h, which shows RAM and swap usage.
				# Displays the output in rofi/dmenu.
				# total   used   free  shared  buff/cache  available
				# Mem:          16Gi    8Gi    4Gi    512Mi     4Gi       7Gi
				# Swap:         2Gi     1Gi    1Gi
                free -h | show_menu
                ;;
        esac
        ;;
	# the script launches Wireshark for network traffic monitoring in a new terminal window
    "📡 Network Traffic")
        # Launch Wireshark for network monitoring
		# gnome-terminal
		# Opens a new terminal window.
		# This ensures Wireshark runs independently of the current session.
		# -- wireshark
		# Runs Wireshark inside the new terminal.
		# If gnome-terminal is not available, Wireshark will still launch in GUI mode.
		# & (Background Execution)
		# Runs Wireshark in the background so the script continues executing.
		# Without &, the script would pause until Wireshark is closed.
        gnome-terminal -- wireshark &
        ;;
    "🔊 Volume Control")
        # Open volume control application
		# pavucontrol (PulseAudio Volume Control)
		# pavucontrol is a GUI-based volume control application.
		# It provides detailed audio settings for input/output devices, applications, and volume levels.
		# Works with PulseAudio, the default sound server in most Linux distributions.
		# & (Background Execution)
		# Runs pavucontrol in the background, allowing the script to continue execution.
		# Without &, the script would pause until pavucontrol is closed.
        pavucontrol &
        ;;
	# the script provides Wi-Fi management options, allowing users to:
	# View available networks
	# Disconnect from Wi-Fi
	# Reconnect to Wi-Fi
    "📶 Wi-Fi Management")
        # Sub-menu for Wi-Fi control
		#Defines WIFI_CHOICE as a menu of Wi-Fi options.
		# Uses show_menu to display the menu and capture user selection.
        WIFI_CHOICE=$(show_menu "📶 Wi-Fi Management\n📡 Available Networks\n🔌 Disconnect\n🔄 Reconnect")
        case "$WIFI_CHOICE" in
            "📡 Available Networks")
                # Show available Wi-Fi networks
				# nmcli → Command-line tool for NetworkManager.
				# device wifi list → Lists available Wi-Fi networks.
				# Pipes (|) the output to show_menu so the user can view and select networks.
				# SSID            MODE   SIGNAL   SECURITY  
				# HomeWiFi       Infra   85       WPA2
				# OfficeWiFi     Infra   70       WPA3
				# GuestNetwork   Infra   50       WPA2
                nmcli device wifi list | show_menu
                ;;
            "🔌 Disconnect")
                # Turn off Wi-Fi
				# radio wifi off → Disables Wi-Fi adapter (like turning off a hardware switch).
				# All Wi-Fi connections are disabled.
				# The user will be disconnected from any active networks.
                nmcli radio wifi off
                ;;
            "🔄 Reconnect")
                # Turn Wi-Fi back on
				# radio wifi on → Enables Wi-Fi adapter (turns it back on).
				# Wi-Fi is re-enabled.
				# The system automatically reconnects to the last connected network (if available).
                nmcli radio wifi on
                ;;
        esac
        ;;
		# the script provides system power management options, allowing users to:
		# Shutdown the system (shutdown now)
		# Reboot the system (reboot)
		# Suspend the system (systemctl suspend)
    "🔋 System Power")
        # Power options sub-menu
		# Defines POWER_CHOICE as a menu of power options.
		# Uses show_menu to display the menu and capture the user’s selection.
        POWER_CHOICE=$(show_menu "🔋 Power Options\n⏻ Shutdown\n🔄 Reboot\n🌙 Suspend")
        case "$POWER_CHOICE" in
            "⏻ Shutdown")
                # Shutdown the system
				# Immediately shuts down the system.
				# Closes all applications and powers off the machine.
				# Requires administrator (root) privileges.
                shutdown now
                ;;
            "🔄 Reboot")
                # Reboot the system
				#Immediately restarts the system.
                reboot
                ;;
            "🌙 Suspend")
                # Suspend system
				# Puts the computer into sleep mode (suspend).
				# RAM remains powered, but the CPU and other hardware are put into low-power mode.
                systemctl suspend
                ;;
        esac
        ;;
    "❌ Quit")
        # Exit the script
		# exit:
		# Terminates the script immediately.
		# Prevents further execution of any remaining commands.
		# exit 0:
		# 0 indicates a successful exit without errors.
		# Conventionally, programs use exit codes to signal success or failure:
		# 0 → Success
		# Non-zero values (e.g., 1, 2, etc.) → Errors or failure states.
        exit 0
        ;;
esac

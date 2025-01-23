#!/bin/bash

# Function to display menu using rofi (if available) or dmenu (fallback)
show_menu() {
    if command -v rofi &>/dev/null; then
        echo -e "$1" | rofi -dmenu -p "📌 Task Manager"
    else
        echo -e "$1" | dmenu -p "📌 Task Manager"
    fi
}

# Confirm action before executing
confirm_action() {
    CONFIRM=$(show_menu "⚠️ Are you sure?\n✅ Yes\n❌ No")
    [[ "$CONFIRM" == "✅ Yes" ]]
}

# Define main menu options
OPTIONS="📂 File Manager\n🔍 Search Files\n📑 Manage Bookmarks\n📂 Recent Files\n⭐ Favorites\n📋 Clipboard Manager\n📸 Take Screenshot\n🔐 Encrypt/Decrypt Files\n🗑️ Trash Manager\n🌦️ Weather Forecast\n🔋 System Uptime & Battery\n🚦 Manage Running Applications\n🖥️ System Management\n📡 Network Traffic\n🔊 Volume Control\n📶 Wi-Fi Management\n🔋 System Power\n❌ Quit"

# Show main menu
CHOICE=$(show_menu "$OPTIONS")

case "$CHOICE" in
    "📂 File Manager")
        xdg-open ~ & ;;
    
    "🔍 Search Files")
        SEARCH_TERM=$(show_menu "Enter filename to search:")
        SELECTED_FILE=$(find ~ -type f -iname "*$SEARCH_TERM*" 2>/dev/null | show_menu)
        [[ -n "$SELECTED_FILE" ]] && xdg-open "$SELECTED_FILE" & ;;
    
    "📑 Manage Bookmarks")
        BOOKMARKS_FILE="$HOME/.bookmarks"
        [[ ! -f "$BOOKMARKS_FILE" ]] && touch "$BOOKMARKS_FILE"

        ACTION=$(show_menu "📌 Bookmarks\n➕ Add\n➖ Remove\n📜 View")
        case "$ACTION" in
            "➕ Add")
                DIR=$(show_menu "Enter directory path:")
                grep -qxF "$DIR" "$BOOKMARKS_FILE" || echo "$DIR" >> "$BOOKMARKS_FILE" ;;
            "➖ Remove")
                TO_REMOVE=$(cat "$BOOKMARKS_FILE" | show_menu)
                [[ -n "$TO_REMOVE" ]] && sed -i "\|$TO_REMOVE|d" "$BOOKMARKS_FILE" ;;
            "📜 View")
                SELECTED_BOOKMARK=$(cat "$BOOKMARKS_FILE" | show_menu)
                [[ -n "$SELECTED_BOOKMARK" ]] && xdg-open "$SELECTED_BOOKMARK" & ;;
        esac ;;
    
    "📂 Recent Files")
        SELECTED_FILE=$(find ~ -type f -printf "%T+ %p\n" | sort -r | head -10 | cut -d' ' -f2- | show_menu)
        [[ -n "$SELECTED_FILE" ]] && xdg-open "$SELECTED_FILE" & ;;
    
    "⭐ Favorites")
        FAVORITES_FILE="$HOME/.favorites"
        [[ ! -f "$FAVORITES_FILE" ]] && touch "$FAVORITES_FILE"

        ACTION=$(show_menu "⭐ Favorites\n➕ Add\n➖ Remove\n📜 View")
        case "$ACTION" in
            "➕ Add")
                FILE=$(show_menu "Enter file path:")
                grep -qxF "$FILE" "$FAVORITES_FILE" || echo "$FILE" >> "$FAVORITES_FILE" ;;
            "➖ Remove")
                TO_REMOVE=$(cat "$FAVORITES_FILE" | show_menu)
                [[ -n "$TO_REMOVE" ]] && sed -i "\|$TO_REMOVE|d" "$FAVORITES_FILE" ;;
            "📜 View")
                SELECTED_FAVORITE=$(cat "$FAVORITES_FILE" | show_menu)
                [[ -n "$SELECTED_FAVORITE" ]] && xdg-open "$SELECTED_FAVORITE" & ;;
        esac ;;

    "📋 Clipboard Manager")
        CLIPBOARD_HISTORY=$(xclip -o -selection clipboard 2>/dev/null | show_menu)
        [[ -n "$CLIPBOARD_HISTORY" ]] && echo "$CLIPBOARD_HISTORY" | xclip -selection clipboard ;;
    
    "📸 Take Screenshot")
        SCREENSHOT_OPTION=$(show_menu "📸 Screenshot Options\n🖥️ Full Screen\n🗔 Active Window\n🔲 Select Region")
        case "$SCREENSHOT_OPTION" in
            "🖥️ Full Screen") scrot ~/Pictures/Screenshot_%Y-%m-%d-%T.png ;;
            "🗔 Active Window") scrot -u ~/Pictures/Screenshot_%Y-%m-%d-%T.png ;;
            "🔲 Select Region") scrot -s ~/Pictures/Screenshot_%Y-%m-%d-%T.png ;;
        esac ;;
    
    "🔐 Encrypt/Decrypt Files")
        CRYPTO_ACTION=$(show_menu "🔐 File Encryption\n🔒 Encrypt File\n🔓 Decrypt File")
        case "$CRYPTO_ACTION" in
            "🔒 Encrypt File")
                FILE_TO_ENCRYPT=$(show_menu "Enter file path to encrypt:")
                PASSWORD=$(show_menu "Enter encryption password:")
                [[ -n "$FILE_TO_ENCRYPT" ]] && openssl enc -aes-256-cbc -salt -in "$FILE_TO_ENCRYPT" -out "$FILE_TO_ENCRYPT.enc" -k "$PASSWORD" ;;
            "🔓 Decrypt File")
                FILE_TO_DECRYPT=$(show_menu "Enter encrypted file path:")
                PASSWORD=$(show_menu "Enter decryption password:")
                [[ -n "$FILE_TO_DECRYPT" ]] && openssl enc -aes-256-cbc -d -in "$FILE_TO_DECRYPT" -out "${FILE_TO_DECRYPT%.enc}" -k "$PASSWORD" ;;
        esac ;;

    "🌦️ Weather Forecast")
        CITY=$(show_menu "Enter city for weather forecast:")
        [[ -n "$CITY" ]] && curl -s "wttr.in/$CITY?format=3" | show_menu ;;
    
    "🔋 System Uptime & Battery")
        UPTIME=$(uptime -p)
        BATTERY=$(acpi -b 2>/dev/null || echo "Battery info not available")
        show_menu "⏳ Uptime: $UPTIME\n🔋 Battery: $BATTERY" ;;

    "🚦 Manage Running Applications")
        SELECTED_APP=$(ps -eo pid,cmd --sort=-%mem | awk '{print $1, $2}' | tail -n +2 | show_menu)
        [[ -n "$SELECTED_APP" ]] && kill -9 $(echo "$SELECTED_APP" | awk '{print $1}') ;;
    
    "🔋 System Power")
        POWER_CHOICE=$(show_menu "🔋 Power Options\n⏻ Shutdown\n🔄 Reboot\n🌙 Suspend\n🚪 Logout\n🔒 Lock Screen")
        case "$POWER_CHOICE" in
            "⏻ Shutdown") confirm_action && shutdown now ;;
            "🔄 Reboot") confirm_action && reboot ;;
            "🌙 Suspend") systemctl suspend ;;
            "🚪 Logout") confirm_action && pkill -KILL -u $USER ;;
            "🔒 Lock Screen") loginctl lock-session ;;
        esac ;;
    
    "❌ Quit")
        confirm_action && exit 0 ;;
esac

#!/bin/bash

# Function to display a menu with rofi or dmenu
show_menu() {
    if command -v rofi &>/dev/null; then
        echo -e "$1" | rofi -dmenu -p "📌 Task Manager"
    else
        echo -e "$1" | dmenu -p "📌 Task Manager"
    fi
}

# Define Menu Options with Emojis
OPTIONS="📂 File Manager\n🔍 Search Files\n📑 Manage Bookmarks\n📂 Recent Files\n⭐ Favorites\n🖥️ System Management\n📡 Network Traffic\n🔊 Volume Control\n📶 Wi-Fi Management\n🔋 System Power\n❌ Quit"

# Display Menu
CHOICE=$(show_menu "$OPTIONS")

case "$CHOICE" in
    "📂 File Manager")
        xdg-open ~
        ;;
    "🔍 Search Files")
        SEARCH_TERM=$(show_menu "Enter filename to search:")
        find ~ -name "*$SEARCH_TERM*" 2>/dev/null | show_menu
        ;;
    "📑 Manage Bookmarks")
        BOOKMARKS_FILE="$HOME/.bookmarks"
        [[ ! -f "$BOOKMARKS_FILE" ]] && touch "$BOOKMARKS_FILE"
        ACTION=$(show_menu "📌 Bookmarks\n➕ Add\n➖ Remove\n📜 View")
        case "$ACTION" in
            "➕ Add")
                DIR=$(show_menu "Enter directory path:")
                echo "$DIR" >> "$BOOKMARKS_FILE"
                ;;
            "➖ Remove")
                TO_REMOVE=$(cat "$BOOKMARKS_FILE" | show_menu)
                sed -i "\|$TO_REMOVE|d" "$BOOKMARKS_FILE"
                ;;
            "📜 View")
                cat "$BOOKMARKS_FILE" | show_menu
                ;;
        esac
        ;;
    "📂 Recent Files")
        find ~ -type f -printf "%T+ %p\n" | sort -r | head -10 | cut -d' ' -f2- | show_menu
        ;;
    "⭐ Favorites")
        FAVORITES_FILE="$HOME/.favorites"
        [[ ! -f "$FAVORITES_FILE" ]] && touch "$FAVORITES_FILE"
        ACTION=$(show_menu "⭐ Favorites\n➕ Add\n➖ Remove\n📜 View")
        case "$ACTION" in
            "➕ Add")
                FILE=$(show_menu "Enter file path:")
                echo "$FILE" >> "$FAVORITES_FILE"
                ;;
            "➖ Remove")
                TO_REMOVE=$(cat "$FAVORITES_FILE" | show_menu)
                sed -i "\|$TO_REMOVE|d" "$FAVORITES_FILE"
                ;;
            "📜 View")
                cat "$FAVORITES_FILE" | show_menu
                ;;
        esac
        ;;
    "🖥️ System Management")
        SYSTEM_OPTIONS="🛠️ System Info\n📌 Running Processes\n💽 Disk Usage\n🚀 RAM Usage"
        SYS_CHOICE=$(show_menu "$SYSTEM_OPTIONS")
        case "$SYS_CHOICE" in
            "🛠️ System Info")
                neofetch | show_menu
                ;;
            "📌 Running Processes")
                ps -ef | show_menu
                ;;
            "💽 Disk Usage")
                df -h | show_menu
                ;;
            "🚀 RAM Usage")
                free -h | show_menu
                ;;
        esac
        ;;
    "📡 Network Traffic")
        gnome-terminal -- wireshark &
        ;;
    "🔊 Volume Control")
        pavucontrol &
        ;;
    "📶 Wi-Fi Management")
        WIFI_CHOICE=$(show_menu "📶 Wi-Fi Management\n📡 Available Networks\n🔌 Disconnect\n🔄 Reconnect")
        case "$WIFI_CHOICE" in
            "📡 Available Networks")
                nmcli device wifi list | show_menu
                ;;
            "🔌 Disconnect")
                nmcli radio wifi off
                ;;
            "🔄 Reconnect")
                nmcli radio wifi on
                ;;
        esac
        ;;
    "🔋 System Power")
        POWER_CHOICE=$(show_menu "🔋 Power Options\n⏻ Shutdown\n🔄 Reboot\n🌙 Suspend")
        case "$POWER_CHOICE" in
            "⏻ Shutdown")
                shutdown now
                ;;
            "🔄 Reboot")
                reboot
                ;;
            "🌙 Suspend")
                systemctl suspend
                ;;
        esac
        ;;
    "❌ Quit")
        exit 0
        ;;
esac

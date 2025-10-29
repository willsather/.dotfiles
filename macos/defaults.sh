#!/usr/bin/env bash

# macOS system defaults configuration script
# matches nix-darwin configuration exactly

set -e

# colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # no color

# helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_info "configuring macos system defaults..."

# close any open system preferences panes
osascript -e 'tell application "System Preferences" to quit'

# ask for the administrator password upfront
sudo -v

# keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# keyboard configuration                                                     #
###############################################################################

# remap caps lock to escape (useful for vim users)
# note: this requires system preferences restart to take effect
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}'

###############################################################################
# menu bar and control center                                               #
###############################################################################

# menu bar clock - show seconds, am/pm, not 24 hour
defaults write com.apple.menuextra.clock Show24Hour -bool false
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock ShowSeconds -bool true

# control center - show battery percentage
defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist BatteryShowPercentage -bool true

###############################################################################
# finder                                                                     #
###############################################################################

# show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# show path bar
defaults write com.apple.finder ShowPathbar -bool true

# show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# enable quit menu item
defaults write com.apple.finder QuitMenuItem -bool true

# disable warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# show full posix path in finder title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

###############################################################################
# screenshots and screensaver                                               #
###############################################################################

# set screenshot location
mkdir -p ~/Pictures/screenshots
defaults write com.apple.screencapture location -string "~/Pictures/screenshots"

# screensaver password delay (10 seconds)
defaults write com.apple.screensaver askForPasswordDelay -int 10

###############################################################################
# dock                                                                       #
###############################################################################

# disable auto-hide
defaults write com.apple.dock autohide -bool false

# don't show recent applications
defaults write com.apple.dock show-recents -bool false

# don't automatically rearrange spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# set persistent apps in dock
defaults write com.apple.dock persistent-apps -array \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Launchpad.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Dia.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Slack.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/WebStorm.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Ghostty.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Zed.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/1Password.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/System Settings.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

###############################################################################
# trackpad                                                                   #
###############################################################################

# enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# set click threshold to medium
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad FirstClickThreshold -int 1

# enable two finger right click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# enable three finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# disable data detector (three finger tap gesture)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 0

###############################################################################
# window manager                                                            #
###############################################################################

# turn off window margins for tiled windows
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

###############################################################################
# global domain settings                                                    #
###############################################################################

# disable natural scrolling (reverse scroll direction)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# enable bottom right corner right-click for trackpad
defaults write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1

# enable force touch
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool true

# disable beep sound when pressing volume keys
defaults write NSGlobalDomain com.apple.sound.beep.feedback -int 0

# enable full keyboard access (mode 3)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# enable press and hold for special characters
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool true

# set key repeat rates (nix: InitialKeyRepeat=15, KeyRepeat=1)
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain KeyRepeat -int 1

# disable auto capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# disable auto dash substitution
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# disable auto period substitution
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

###############################################################################
# touch id for sudo                                                         #
###############################################################################

# enable touch id for sudo authentication
if ! grep -q "pam_tid.so" /etc/pam.d/sudo_local 2>/dev/null; then
    sudo sh -c 'echo "auth       sufficient     pam_tid.so" >> /etc/pam.d/sudo_local'
    log_success "touch id enabled for sudo authentication"
fi

###############################################################################
# kill affected applications                                                 #
###############################################################################

for app in "Activity Monitor" \
    "Address Book" \
    "Calendar" \
    "cfprefsd" \
    "Contacts" \
    "Dock" \
    "Finder" \
    "Mail" \
    "Messages" \
    "Photos" \
    "Safari" \
    "SystemUIServer" \
    "Terminal" \
    "iCal"; do
    killall "${app}" &> /dev/null || true
done

log_success "macos system defaults configured successfully!"
log_info "note: some changes require a logout/restart to take effect."
log_info "caps lock -> escape mapping will be active after restart."

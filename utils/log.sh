#!/usr/bin/env bash

# Shared logging utilities for dotfiles scripts
# Provides consistent color-coded logging functions across all scripts

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Logging functions
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

log_debug() {
    if [[ "${DEBUG:-}" == "1" ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1"
    fi
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

log_header() {
    echo
    echo -e "${WHITE}==== $1 ====${NC}"
    echo
}

# Progress indicator functions
log_progress() {
    local current="$1"
    local total="$2"
    local message="$3"
    echo -e "${BLUE}[PROGRESS]${NC} ($current/$total) $message"
}

# Simple spinner for long-running operations
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'

    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Execute command with logging
log_exec() {
    local cmd="$1"
    local success_msg="${2:-Command executed successfully}"
    local error_msg="${3:-Command failed}"

    log_debug "Executing: $cmd"

    if eval "$cmd"; then
        log_success "$success_msg"
        return 0
    else
        log_error "$error_msg"
        return 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Log command availability check
log_check_command() {
    local cmd="$1"
    local name="${2:-$1}"

    if command_exists "$cmd"; then
        log_success "$name is available"
        return 0
    else
        log_warning "$name is not available"
        return 1
    fi
}

#!/bin/bash

# Clear the screen and set trap for signals
echo -ne '\033c'
trap 'echo -e "\nProcess interrupted. Exiting..."; exit 1' SIGINT SIGQUIT SIGTSTP

# Function to check if Docker is installed and running
check_docker() {
    if ! command -v docker &>/dev/null; then
        echo -e "\nDocker is not installed. Please install Docker first."
        exit 1
    fi

    if ! systemctl is-active --quiet docker; then
        echo -e "\nDocker is not running. Please start the Docker service."
        exit 1
    fi
}

# Display the menu
display_menu() {
    echo -e "\033[36m    +\033[33m--------------------------------------------------------------------------------------------------------------------------\033[36m+"
    echo -e "\033[33m     |                                                                                                                        |"
    echo -e "     | \033[32m   ██████╗ ███╗   ██╗██╗     ██╗███╗   ██╗███████╗     \033[31mBrowser Installer\033[33m                                         |"
    echo -e "\033[36m    +\033[33m--------------------------------------------------------------------------------------------------------------------------\033[36m+"
    echo -e "                                     | \033[32mChoose a browser to install via Docker\033[33m                                   |"
    echo -e "                                     \033[36m+\033[33m--------------------------------------------------------\033[36m+"
    echo -e "\033[33m     +\033[37m-------------------------------------------------------------------\033[33m+"
    echo -e "\033[37m     | \033[33m ID \033[37m |                   \033[35m   Browser Name                       \033[37m   |"
    echo -e "\033[33m     +\033[37m-------------------------------------------------------------------\033[33m+"
    echo -e "\033[37m     | \033[31m[\033[33m1\033[31m]\033[37m | \033[32mInstall Chromium\033[37m                                           |"
    echo -e "\033[37m     | \033[31m[\033[33m2\033[31m]\033[37m | \033[32mInstall Firefox\033[37m                                            |"
    echo -e "\033[37m     | \033[31m[\033[33m3\033[31m]\033[37m | \033[32mInstall Opera\033[37m                                              |"
    echo -e "\033[37m     | \033[31m[\033[33m4\033[31m]\033[37m | \033[32mInstall Mullvad Browser\033[37m                                    |"
    echo -e "\033[33m     +\033[37m-------------------------------------------------------------------\033[33m+"
    echo -e "\n\033[37m [\033[36m!Note:\033[37m] Enter the number corresponding to your choice (e.g., \033[32m1\033[37m for Chromium).\n"
}

# Function to get user input for ports and directories
get_user_input() {
    echo -e "\n\033[37m Enter the port for the browser's web interface (default: \033[32m3000\033[37m): "
    read -r browser_port
    browser_port=${browser_port:-3000}

    echo -e "\n\033[37m Enter the port for the browser's VNC interface (default: \033[32m3001\033[37m): "
    read -r vnc_port
    vnc_port=${vnc_port:-3001}

    echo -e "\n\033[37m Enter the directory for browser configuration files (default: \033[32m~/browser-config\033[37m): "
    read -r config_dir
    config_dir=${config_dir:-~/browser-config}
    mkdir -p "$config_dir"
}

# Function to install the selected browser
install_browser() {
    local browser_name=$1
    local docker_image=$2

    echo "Installing $browser_name..."
    docker run -d \
        --name="$browser_name" \
        --security-opt seccomp=unconfined \
        -e PUID=1000 \
        -e PGID=1000 \
        -e TZ=Etc/UTC \
        -p "$browser_port:3000" \
        -p "$vnc_port:3001" \
        -v "$config_dir/$browser_name:/config" \
        --shm-size="7gb" \
        --restart unless-stopped \
        "$docker_image"
    echo -e "\n\033[32m✔ $browser_name installa

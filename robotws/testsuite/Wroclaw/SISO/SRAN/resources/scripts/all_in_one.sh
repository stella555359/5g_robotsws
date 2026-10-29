#!/bin/bash

# Defining colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
GRAY='\033[0;90m'
FLASHING='\033[0;05m'
NC='\033[0m'

show_menu() {
    echo -e "<========================================>"
    echo -e "Contact person: krzysztof.pekala@nokia.com"
    echo -e "<========================================>"
    echo -e "${GREEN}Select a script to run:${NC}"
    echo -e "${CYAN} ------- Common (option: 1-20) ------- ${NC}"
    echo -e "${YELLOW}1) downloadSW${NC} --> ${GRAY}Downloading SBTS software from Artifactory to a VM${NC}"
    echo -e "${YELLOW}2) burak_installation${NC} --> ${GRAY}Installation of burak: Global_verification and IAV_WCDMA${NC}"
    echo -e "${YELLOW}3) noping_installation${NC} --> ${GRAY}(for: UTE VMs) -> Program for pinging multiple addresses at once${NC}"
    echo -e "${YELLOW}4) noping_installation${NC} --> ${GRAY}(for: VEM VMs) -> Program for pinging multiple addresses at once${NC}"
    echo -e "${YELLOW}5) BSC_login${NC} --> ${RED}sshpass required${NC}"
    echo -e "${YELLOW}6) BTS_login_192.168.255.129${NC} --> ${RED}sshpass required (may ask also for ssh-keygen)${NC}"
    echo -e "${YELLOW}7) BTS_login_192.168.255.119${NC} --> ${RED}sshpass required (may ask also for ssh-keygen)${NC}"
    echo -e "${YELLOW}8) BTS_login_192.168.255.1${NC} --> ${RED}sshpass required (may ask also for ssh-keygen)${NC}"
    echo -e "${YELLOW}9) YAFT installation${NC}"

    # echo -e "${CYAN} ------- RobotLTE (option: 10-13) ------- ${NC}"
    # echo -e "${PURPLE}10) RobotLTE_installation${NC} --> ${GRAY}Full installation of the RobotLTE environment${NC}"
    # echo -e "${PURPLE}11) RobotLTE_FULL_update${NC}"
    # echo -e "${PURPLE}12) RobotLTE_Repository_Check${NC}"
    # echo -e "${PURPLE}13) RobotLTE_update_repository${NC}"

    echo -e "${CYAN} ------- RobotWS (option: 20-40) ------- ${NC}"
    echo -e "${BLUE}20) RobotWS_installation${NC} --> ${GRAY}Full installation of the RobotWS environment${NC}"
    echo -e "${BLUE}21) RobotWS_FULL_update${NC}"
    echo -e "${BLUE}22) RobotWS_Repository_Check${NC}"
    echo -e "${BLUE}23) RobotWS_update_repository${NC}"
    echo -e "${BLUE}24) RobotWS_csv4all_update${NC} --> ${GRAY}Update UUF repository${NC}"
    echo -e "${BLUE}25) RobotWS_aliases_update${NC} --> ${GRAY}If: bash: robot: command not found${NC}"
    echo -e "${BLUE}26) RobotWS_library_common_resources_update${NC}"
    echo -e "${BLUE}27) RobotWS_library_common_resources_version_check${NC}"
    echo -e "${BLUE}28) pcmanfm_open_location${NC} --> ${GRAY}Open File Explorer with important locations for RobotWS${NC}"
    echo -e "${BLUE}29) terminator_open_location${NC} --> ${GRAY}Open few tabs in Terminator with important locations${NC}"
    echo -e "${BLUE}30) delete_unnecessary_files_RobotWS${NC} --> ${GRAY}Remove unnecessary files from /home/ute/MN/UTE/robotws${NC}"

    echo -e "${CYAN} ------- EXIT (option: 50) ------- ${NC}"
    echo -e "${YELLOW}50) Exit${NC}"

    echo -e "${CYAN} ------- Additional content: Required drivers (option: 100-103) ------- ${NC}"
    echo -e "${RED}100) sshpass${NC}"
    echo -e "${RED}101) ssh-keygen .1${NC}"
    echo -e "${RED}102) ssh-keygen .119${NC}"
    echo -e "${RED}103) ssh-keygen .129${NC}"
}

# ----------------------------------------------------
# ----------------------------------------------------
# 1 ----------------------------------------------------

run_downloadSW() {
    read -p "Enter full SW build (e.g.: SBTS24R3_ENB_0000_000129_000000): " SW
    nazwa=$(echo ${SW} | cut -d '_' -f 1)
    cd /home/ute/Downloads
    wget https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/$nazwa/$SW/${SW}_release_BTSSM_downloadable_A54.zip
}

# 2 ----------------------------------------------------

# Function running the script burak (Author: Slawomir.Jastrzebski@nokia.com)
run_burak() {
    cd /home/ute/Downloads
    wget https://wrgitlab.int.net.nokia.com/jastrzeb/hello/-/raw/master/mount_burak.sh
    chmod 777 mount_burak.sh
    sudo ./mount_burak.sh
    rm mount_burak.sh
}

# 3 ----------------------------------------------------

run_noping_installation_ute() {
    FILE="/etc/apt/sources.list.d/debian_repo.list"

    if [ ! -f "$FILE" ]; then
    sudo touch "$FILE"
    fi

    sudo bash -c "cat <<EOL > $FILE
    deb https://artifactory-espoo2.int.net.nokia.com/artifactory/deb-debian-org-remote bookworm main contrib non-free non-free-firmware
    deb https://artifactory-espoo2.int.net.nokia.com/artifactory/deb-debian-org-remote bookworm-updates main contrib non-free non-free-firmware
    deb https://artifactory-espoo2.int.net.nokia.com/artifactory/deb-debian-org-remote bookworm-backports main contrib non-free non-free-firmware
    deb https://artifactory-espoo1.int.net.nokia.com/artifactory/security-debian-org-remote bookworm-security main contrib non-free non-free-firmware"

    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y oping
}

# 4 ----------------------------------------------------

run_noping_installation_vem() {
    cd
    sudo apt-get install oping

    echo -e "${GREEN}Now you can use command for multipinging (e.g. noping 192.168.255.1 192.168.255.119 192.168.255.129)${NC}"
}

# 5 ----------------------------------------------------

# Function for logging into BSC
run_BSC_login() {

# Function to check if sshpass is installed
check_sshpass_installed() {
    if ! command -v sshpass &> /dev/null; then
        echo "sshpass is not installed. Installing..."
        sudo apt-get update
        sudo apt-get install -y sshpass
    else
        echo -e "${GREEN}Script for logging into BSC. Choose a number, and the script will log in for you:)${NC}"
    fi
}

# Function for logging into the server using sshpass
login_to_server() {
    local server_ip
    local username
    local password

    echo -e "${CYAN} ------- Choose BSC server: (option: 1-10) ------- ${NC}"
    echo -e "${RED}1) ${YELLOW}asBSC-23 ${NC}(WRO WL)"
    echo -e "${RED}2) ${YELLOW}asBSC-24 ${NC}(WRO WL)"
    echo -e "${RED}3) ${YELLOW}asBSC-25 ${NC}(WRO WL)"
    echo -e "${RED}4) ${YELLOW}asBSC-21 ${NC}(WRO WG - PZUSER4)"
    echo -e "${RED}5) ${YELLOW}asBSC-21 ${NC}(WRO WG - PZUSER)"
    echo -e "${RED}6) ${YELLOW}mcBSC-K2O ${NC}(WRO GT)"
    echo -e "${RED}7) ${YELLOW}mcBSC-R2D2 ${NC}(WRO GT - PZUSER1)"
    echo -e "${RED}8) ${YELLOW}mcBSC-R2D2 ${NC}(WRO GT - PZUSER2)"
    echo -e "${RED}9) ${YELLOW}mcBSC-R2D2 ${NC}(WRO GT - PZUSER3)"
    echo -e "${RED}10) ${YELLOW}mcBSC-R2D2 ${NC}(WRO GT - PZUSER4)"
    read -p "Choose an option: " choice

    case $choice in
        1)
            server_ip="10.42.23.26"
            username="VRFUSER"
            password="VRFPASSWORD"
            ;;
        2)
            server_ip="10.42.196.170"
            username="VRFUSER"
            password="VRFPASSWORD"
            ;;
        3)
            server_ip="10.42.196.183"
            username="VRFUSER"
            password="VRFPASSWORD"
            ;;
        4)
            server_ip="10.42.28.126"
            username="PZUSER4"
            password="Ut3pa5s#1be1"
            ;;
        5)
            server_ip="10.42.28.126"
            username="PZUSER"
            password="pzpassword"
            ;;
        6)
            server_ip="10.42.107.4"
            username="PZUSER3"
            password="pzpass3"
            ;;
        7)
            server_ip="10.42.4.132"
            username="PZUSER1"
            password="pzpass1"
            ;;
        8)
            server_ip="10.42.4.132"
            username="PZUSER2"
            password="pzpass2"
            ;;
        9)
            server_ip="10.42.4.132"
            username="PZUSER3"
            password="pzpass3"
            ;;
        10)
            server_ip="10.42.4.132"
            username="PZUSER4"
            password="Ut3pa5s#1be1"
            ;;
        *)
            echo "Invalid choice."
            exit 1
            ;;
    esac

    # Using sshpass to log in
    sshpass -p "$password" ssh "$username@$server_ip"
}

# Checking if sshpass is installed, then logging in
check_sshpass_installed
login_to_server
}

# 6 ----------------------------------------------------

run_BTS_login_primaryCore() {
# Login data
LOGIN="toor4nsn"
PASSWORD="oZPS0POrRieRtu"
IP_ADDRESS="192.168.255.129"

# Logging in via SSH
sshpass -p $PASSWORD ssh $LOGIN@$IP_ADDRESS
}


# 7 ----------------------------------------------------

run_BTS_login_secondaryCore() {
# Login data
LOGIN="toor4nsn"
PASSWORD="oZPS0POrRieRtu"
IP_ADDRESS="192.168.255.119"

# Logging in via SSH
sshpass -p $PASSWORD ssh $LOGIN@$IP_ADDRESS
}

# 8 ----------------------------------------------------

run_BTS_login_serviceCore() {
# Login data
LOGIN="toor4nsn"
PASSWORD="oZPS0POrRieRtu"
IP_ADDRESS="192.168.255.1"

# Logging in via SSH
sshpass -p $PASSWORD ssh $LOGIN@$IP_ADDRESS
}

# 9 ----------------------------------------------------

run_YAFT_installation() {
#  echo -e "${GREEN}Credentials:${NC}"
  echo -e "${GREEN}Credentials to VM: login: ute || pass: (your pass to VM)${NC}"
  echo -e "${GREEN}Credentials to SVN: username: ca_ute_test || pass: utetest${NC}"
  cd /home/ute/Downloads
  svn co https://svne1.access.nsn.com/isource/svnroot/BTS_T_YAFT/trunk/ YAFT
  sudo apt update
  sudo apt upgrade
  pip install paramiko
  pip install paramiko --upgrade
}


# ----------------------------------------------------
# RobotLTE
# https://confluence.ext.net.nokia.com/display/mnsranprodsisopz/Preparing+new+VM+for+robotlte
# 10 ----------------------------------------------------

# # Function running the script RobotLTE_installation
# run_RobotLTE_installation() {
#     read -p "Enter number of your TL (e.g. 1299): " TL_number
#     read -p "Enter number of your Team (e.g. WRO5): " Team_number
#     cd /home/ute/Downloads
#     wget https://wrgitlab.int.net.nokia.com/jastrzeb/hello/-/raw/master/mount_burak.sh
#     chmod 777 mount_burak.sh
#     sudo ./mount_burak.sh
#     rm mount_burak.sh
#     sudo apt-get install oping
#     cd
#     ute install latest
#     pyenv install 3.9.14
#     pyenv global 3.9.14
#     cd /home/ute/MN/UTE/robotlte
#     git pull origin master
#     cd /home/ute/testline_configuration
#     git pull origin master
#     cd
#     rm -r /home/ute/test_repo
#     python -m venv /home/ute/test_repo
#     source /home/ute/test_repo/bin/activate
#     pip install -r /home/ute/MN/UTE/robotlte/dependencies.py39.lock
#     deactivate
#     echo 'alias robot="source /home/ute/test_repo/bin/activate; robot"; alias pybot="source /home/ute/test_repo/bin/activate; robot";' >> ~/.bashrc
#     cd /home/ute/testline_configuration
#     rm -r *
#     mkdir "TL$TL_number"
#     cd "TL$TL_number"
#     touch README.txt
#     echo -e "Here put a __init__.py file with all information about hardware." > README.txt
#     cp "/media/burak/09_Users/Pekala/instrukcje/Skrypty/RobotLTE_init&robot_files/downloads/__init__example_file_singleCore.py" "/home/ute/testline_configuration/TL${TL_number}/__init__example_file_singleCore.py"
#     cp "/media/burak/09_Users/Pekala/instrukcje/Skrypty/RobotLTE_init&robot_files/downloads/__init__example_file_dualCore.py" "/home/ute/testline_configuration/TL${TL_number}/__init__example_file_dualCore.py"
#     pcmanfm
#     cd /home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/AiFSiteS/Integration/$Team_number
#     mkdir "TL$TL_number"
#     cd "TL$TL_number"
#     touch README.txt
#     echo -e "Here put a $TL_number.robot file with list of automation tests." > README.txt
#     cp "/media/burak/09_Users/Pekala/instrukcje/Skrypty/RobotLTE_init&robot_files/downloads/TLxxxx_example_file.robot" "/home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/AiFSiteS/Integration/$Team_number/TL${TL_number}/${TLx}"
#     pcmanfm
# }

# # 11 ----------------------------------------------------

# # Function running the script RobotLTE_update
# run_RobotLTE_FULL_update() {
#     cd
#     ute install latest
#     cd /home/ute/MN/UTE/robotlte
#     git pull origin master
#     cd
#     rm -r /home/ute/test_repo
#     python -m venv /home/ute/test_repo
#     source /home/ute/test_repo/bin/activate
#     pip install -r /home/ute/MN/UTE/robotlte/dependencies.py39.lock
#     deactivate
# }

# # 12 ----------------------------------------------------

# # Function running the script before_Update_RobotWS_Repository_Check
# run_RobotLTE_Repository_Check() {
#     cd
#     cd MN/UTE/robotlte
#     git status
# }

# # 13 ----------------------------------------------------

# # Function running the script RobotLTE_update_repository
# run_RobotLTE_update_repository() {
#     cd /home/ute/MN/UTE/robotws
#     git pull origin master
# }

# ----------------------------------------------------
# RobotWS
# https://confluence.ext.net.nokia.com/display/mnsranprodsisopz/Preparing+new+VM+for+robotws
# 20 ----------------------------------------------------

# Function running the script RobotWS_installation
run_RobotWS_installation() {
    echo -e "${GREEN}Once installation is complete, close the terminal.${NC}"
    read -p "Enter number of your TL (e.g. 10_16_UTESRANSISO133): " TL_number
    cd /home/ute
    ute install latest
    pyenv global 3.10.12
    cd /home/ute/MN/UTE/robotws
    git pull origin master
    cd
    cd /home/ute/testline_configuration
    git pull origin master
    cd
    rm -r /home/ute/test_repo
    python -m venv /home/ute/test_repo
    source /home/ute/test_repo/bin/activate
    pip install -r /home/ute/MN/UTE/robotws/dependencies.py310-rf50.lock
    deactivate
    #bash
    echo 'alias robot="source /home/ute/test_repo/bin/activate; robot"; alias pybot="source /home/ute/test_repo/bin/activate; robot";' >> ~/.bashrc

    mkdir /home/ute/testline_configuration/"${TL_number}"
    cd /home/ute/testline_configuration/$TL_number
    touch README.txt
    echo "__init__.py file." > README.txt
    pcmanfm
    
    cd #node_1
    mkdir -p testline_init_results/execution/configs/topology_configs/node_1
    cd /home/ute/testline_init_results/execution/configs/topology_configs/node_1
    touch README.txt
    echo "SCF.xml , config.yaml , swconfig.txt files." > README.txt
    pcmanfm
    cd #node_2
    mkdir -p testline_init_results/execution/configs/topology_configs/node_2
    cd /home/ute/testline_init_results/execution/configs/topology_configs/node_2
    touch README.txt
    echo "In case of dual core: SCF.xml , config.yaml , swconfig.txt files. If single core, delete 'node_2' directory." > README.txt
    
    mkdir /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestLines/"${TL_number}"
    cd /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestLines/$TL_number
    touch README.txt
    echo ".robot file with TCs" > README.txt
    pcmanfm
}

# 21 ----------------------------------------------------

# Function running the script Full_RobotWS_update
run_RobotWS_FULL_update() {
    cd
    ute install latest
    cd /home/ute/MN/UTE/robotws
    git pull origin master
    cd
    rm -r /home/ute/test_repo
    python -m venv /home/ute/test_repo
    source /home/ute/test_repo/bin/activate
    pip install -r /home/ute/MN/UTE/robotws/dependencies.py310-rf50.lock
    deactivate
}

# 22 ----------------------------------------------------

# Function running the script before_Update_RobotWS_Repository_Check
run_RobotWS_Repository_Check() {
    cd
    cd MN/UTE/robotws
    git status
}

# 23 ----------------------------------------------------

# Function running the script RobotWS_update_repository
run_RobotWS_update_repository() {
    cd /home/ute/MN/UTE/robotws
    git pull origin master
}

# 24 ----------------------------------------------------

# Function running the script RobotWS_csv4all_update
run_RobotWS_csv4all_update() {
    cd
    source test_repo/bin/activate
    pip install -U taf.rfrl.csv4all
}

# 25 ----------------------------------------------------

# Function running the script RobotWS_aliases_update
run_RobotWS_aliases_update() {
    echo 'alias robot="source /home/ute/test_repo/bin/activate; robot";
    alias pybot="source /home/ute/test_repo/bin/activate; robot";' >> ~/.bashrc
}

# 26 ----------------------------------------------------

# Function running the script RobotWS_library_common_resources_update
run_RobotWS_library_common_resources_update() {
    cd
    source test_repo/bin/activate
    pip install -U taf.rfrl.common_resources
}

# 27 ----------------------------------------------------

# Function running the script RobotWS_library_common_resources_version_check
run_RobotWS_library_common_resources_version_check() {
    cd
    source test_repo/bin/activate
    pip show taf.rfrl.common_resources
}

# 28 ----------------------------------------------------

# Function running the script pcmanfm_open_location
run_pcmanfm_open_location() {
  
set -euo pipefail

read -p "Enter number of your TL (e.g. 10_16_UTESRANSISO133 or TL1260...): " TL_number

# Dwie stałe lokalizacje
PATHS=(
  "/home/ute/Downloads"
  "/home/ute"
  # "/home/ute/MN/UTE/robotws"
  "/home/ute/testline_configuration/$TL_number"
  "/home/ute/testline_init_results/execution/configs/topology_configs"
  "/home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestLines/$TL_number"
  "/tmp"
)

# Wykryj PCManFM (Qt lub GTK)
FM_CMD=$(command -v pcmanfm-qt || command -v pcmanfm 2>/dev/null || true)
if [ -z "$FM_CMD" ]; then
  echo "PCManFM nie znaleziony. Zainstaluj pcmanfm-qt lub pcmanfm (np. sudo apt install pcmanfm-qt)." >&2
  exit 1
fi

# Sprawdź, czy PCManFM obsługuje --new-window (opcjonalnie)
uses_new_window=0
if "$FM_CMD" --help 2>&1 | grep -q -- '--new-window'; then
  uses_new_window=1
fi

# Otwórz każdą lokalizację (w nowym oknie, jeśli opcja jest dostępna)
for dir in "${PATHS[@]}"; do
  if [ -d "$dir" ]; then
    if [ "$uses_new_window" -eq 1 ]; then
      "$FM_CMD" --new-window "$dir" &
    else
      "$FM_CMD" "$dir" &
    fi
  else
    echo "Ostrzeżenie: '$dir' nie istnieje lub nie jest katalogiem. Pomijam." >&2
  fi
done

}


# 29 ----------------------------------------------------

# Function running the script terminator_open_location
run_terminator_open_location() {

set -euo pipefail

# Dwie stałe lokalizacje (na sztywno)
PATHS=(
  "/home/ute"
  "/home/ute/MN/UTE/robotws"
  "/home/ute/Downloads"
)

# Sprawdź, czy Terminator jest zainstalowany
TERMINATOR=$(command -v terminator)
if [ -z "$TERMINATOR" ]; then
  echo "Terminator nie jest zainstalowany. Zainstaluj go: sudo apt install terminator" >&2
  exit 1
fi

# Czy Terminator obsługuje --new-tab?
NEW_TAB_OPTS=""
if "$TERMINATOR" --help 2>&1 | grep -q -- '--new-tab'; then
  NEW_TAB_OPTS="--new-tab"
fi

# Czy istnieje już uruchomiony Terminator?
if pgrep -x "terminator" >/dev/null; then

# Istnieje uruchomiony Terminator — spróbuj dodać nowe karty
  for dir in "${PATHS[@]}"; do
    if [ -d "$dir" ]; then
      if [ -n "$NEW_TAB_OPTS" ]; then
        "$TERMINATOR" $NEW_TAB_OPTS -e "bash -lc 'cd "$dir"; exec bash'"
      else
        # Brak opcji nowych kart w tej wersji — otwórz nowy okno
        "$TERMINATOR" -e "bash -lc 'cd "$dir"; exec bash'"
      fi
    else
      echo "Ostrzeżenie: '$dir' nie istnieje, pomijam." >&2
    fi
  done
else

# Nie ma uruchomionego Terminatora — otwieramy okna/karty od razu
  if [ -n "$NEW_TAB_OPTS" ]; then
    "$TERMINATOR" $NEW_TAB_OPTS -e "bash -lc 'cd "${PATHS[0]}"; exec bash'"
    "$TERMINATOR" $NEW_TAB_OPTS -e "bash -lc 'cd "${PATHS[1]}"; exec bash'"
  else
    "$TERMINATOR" -e "bash -lc 'cd "${PATHS[0]}"; exec bash'"
    "$TERMINATOR" -e "bash -lc 'cd "${PATHS[1]}"; exec bash'"
  fi
fi

}

# 30 ----------------------------------------------------

# Function running the script delete_unnecessary_files_RobotWS
run_delete_unnecessary_files_RobotWS() {
  rm /home/ute/MN/UTE/robotws/admin_api_node_mrbts_admin*;
  rm /home/ute/MN/UTE/robotws/wget-log*;
  rm /home/ute/MN/UTE/robotws/prepare-firmware*;
  rm /home/ute/MN/UTE/robotws/dependencies.py3*;
  ls
}

# 100 ----------------------------------------------------

# Function running the script sshpass

run_sshpass() {

sudo apt-get update
sudo apt-get install -y sshpass

# Confirm installation
if command -v sshpass &> /dev/null
then
    echo "sshpass has been successfully installed."
else
    echo "Issue while installing sshpass."
fi
}

# 101 ----------------------------------------------------

run_sshKeygen_1() {
ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "192.168.255.1"
}

# 102 ----------------------------------------------------

run_sshKeygen_119() {
ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "192.168.255.119"
}

# 103 ----------------------------------------------------

run_sshKeygen_129() {
ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "192.168.255.129"
}

# ----------------------------------------------------
# ----------------------------------------------------
# ----------------------------------------------------

# Main menu loop
while true; do
    show_menu
    read -p "Choose an option: " choice
    case $choice in
        1) run_downloadSW ;;
        2) run_burak ;;
        3) run_noping_installation_ute ;;
        4) run_noping_installation_vem ;;
        5) run_BSC_login ;;
        6) run_BTS_login_primaryCore ;;
        7) run_BTS_login_secondaryCore ;;
        8) run_BTS_login_serviceCore ;;
        9) run_YAFT_installation ;;
        # 10) run_RobotLTE_installation ;;
        # 11) run_RobotLTE_FULL_update ;;
        # 12) run_RobotLTE_Repository_Check ;;
        # 13) run_RobotLTE_update_repository ;;
        20) run_RobotWS_installation ;;
        21) run_RobotWS_FULL_update ;;
        22) run_RobotWS_Repository_Check ;;
        23) run_RobotWS_update_repository ;;
        24) run_RobotWS_csv4all_update ;;
        25) run_RobotWS_aliases_update ;;
        26) run_RobotWS_library_common_resources_update ;;
        27) run_RobotWS_library_common_resources_version_check ;;
        28) run_pcmanfm_open_location ;;
        29) run_terminator_open_location ;;
        30) run_delete_unnecessary_files_RobotWS ;;
        50) echo "Goodbye!"; exit 0 ;;
        100) run_sshpass ;;
        101) run_sshKeygen_1 ;;
        102) run_sshKeygen_119 ;;
        103) run_sshKeygen_129 ;;
        *) echo "Invalid option. Try again." ;;
    esac
done

#!/bin/bash                                                                                                                                                                                                    
# Description: Adds useful aliases for testline managing
# Author: Dawid Chuchnowski 
# Date: 2025-06-23
# Version: 1.0 

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
 
function error {
    printf "[ ${RED}ERROR${NC} ][ $(date +%T) ]\t${*}\n"
}

function info {
    printf "[ ${GREEN}INFO${NC} ][ $(date +%T) ]\t${*}\n"
}
info "Testline preparation script started"

info "Add aliases"
grep -qi 'RAN_PZ_KRK6/krk6_aliases.sh' ~/.bashrc || echo 'source /home/ute/MN/UTE/robotws/testsuite/Krakow/resources/RAN_PZ_KRK6/krk6_aliases.sh'  >> ~/.bashrc

info "Add custom functions"
grep -qi 'RAN_PZ_KRK6/functions.sh' ~/.bashrc || echo 'source /home/ute/MN/UTE/robotws/testsuite/Krakow/resources/RAN_PZ_KRK6/functions.sh'  >> ~/.bashrc

info "Add KRK6 resources to PATH"
grep -qxF 'export PATH=${PATH}:/home/ute/MN/UTE/robotws/testsuite/Krakow/resources/RAN_PZ_KRK6' ~/.bashrc || echo "export PATH=\${PATH}:/home/ute/MN/UTE/robotws/testsuite/Krakow/resources/RAN_PZ_KRK6" >> $HOME/.bashrc

info "Testline preparation completed"

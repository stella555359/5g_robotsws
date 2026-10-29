#!/bin/bash
#Author:Rosa Adrian
#Modif:Dan Moldovan # fot Trunk tot use directly the proposed Regression Build



GREENB='\033[0;41m'
GREEN='\033[0;32m'
REDB='\033[0;41m'
RED='\033[0;31m'
NORMALB='\033[0;49m'
NORMAL='\033[0m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color
TOKEN="cmVmdGtuOjAxOjE4MTE5MjkyOTU6WDQzTmRQRDlXeFhrNlpUN2xzTk1vR3R1SmU2"


# Define the version of this script
CURRENT_VERSION="2.0.1"

# Print the current version
echo "Current version: $CURRENT_VERSION"

# Download the script with a new name to check the version
curl -s -o new_lazy_vdu_upgrade.sh https://wrgitlab.int.net.nokia.com/adrosa/lazy_vdu_upgrade/-/raw/main/lazy_vdu_upgrade.sh?inline=false


#source new_lazy_vdu_upgrade.sh
NEW_VERSION=$(grep -oP 'CURRENT_VERSION="\K[0-9.]+' new_lazy_vdu_upgrade.sh)

# If the new version is the same as the current version, delete the new script and continue
if [[ "$NEW_VERSION" == "$CURRENT_VERSION" ]]; then
    rm new_lazy_vdu_upgrade.sh
    echo -e "${GREEN}The script is up-to-date.${NC}"
else
    # If the new version is different, replace the current script with the new one
    mv new_lazy_vdu_upgrade.sh lazy_vdu_upgrade.sh
    chmod +x lazy_vdu_upgrade.sh
    echo "Script updated to version $NEW_VERSION."
    echo -e "${RED}RUN THE SCRIPT AGAIN.${NC}"
    exit 1
fi
#oc delete mc 40-master-idle-connection-config
# Define the configuration file
#CONFIG_FILE="/etc/systemd/logind.conf.d/01-nokia-ssh-idle-config.conf"

# Check if StopIdleSessionSec is already set to 3600
#if ! grep -q '^StopIdleSessionSec=3600' "$CONFIG_FILE"; then
#    # Update the value to 3600
#    sudo sed -i 's/^StopIdleSessionSec=.*/StopIdleSessionSec=3600/' "$CONFIG_FILE"
#    # Restart the systemd-logind service
#    sudo systemctl reload-or-restart systemd-logind.service
#
#    echo "Updated StopIdleSessionSec to 3600 and restarted systemd-logind."
#else
#    echo ""
#fi

#Rest of your script starts here



REGRESSION_BUILD=$(curl -s -X GET 'https://wft.int.net.nokia.com:8091/api/v1/view/3421.json?access_key=pVOA88KVZKpVxSCqmrVjzur7N0BYD1Iz5YU1KCb5&project_filters=CRAN' \
| jq -r '.items.REGRESSION[] | "\(.["build.baseline"])       \(.["created_at"] | sub("T.*$"; ""))"' \
| grep -v '^vCUCNF' \
| sed -E 's/^vDUCNF[0-9]+R[0-9]+_//; s/^vDUCNF00_//' \
| grep -E '^([0-9]{2})\.300\.[0-9]+[[:space:]]' \
| sort -n)

REGRESSION_BUILD2=$(curl -s -X GET 'https://wft.int.net.nokia.com:8091/api/v1/view/3421.json?access_key=pVOA88KVZKpVxSCqmrVjzur7N0BYD1Iz5YU1KCb5&project_filters=CRAN' \
| jq -r '.items.REGRESSION[] | "\(.["build.baseline"])      \(.["created_at"] | sub("T.*$"; ""))"' \
| grep '^vDUCNF00_' \
| sed 's/^vDUCNF00_//' \
| grep -E '0.300\.[0-9]+[[:space:]]' \
| sort -n)



REG_00GET=$(echo -e "\033[0;32m$REGRESSION_BUILD2\033[0m" | head -n 1)
REG_00=$(echo -e "\033[0;32m$REG_00GET \033[0m <-REGRESSION BUILD \033[0m")
REG_00_BUILD=$(echo -e "$REG_00" | awk '{print $1}')
REG_OLD=$(echo -e "\033[0;32mREGRESSION:$REGRESSION_BUILD\033[0m" | tail -n 1)
REG_OLDER=$(echo -e "\033[0;32m$REG_OLD \033[0m <-REGRESSION BUILD")
SECTION_BUILD="VDU_BUILD_INFO"
SECTION_VERSION="CONFIG_FILE"
FILE1="./artifacts/vdu_config.ini"
FILE2="./templates/vdu_config.template"
BUILD="build_version"
VERSION="version"
default_build=""
cols=$(tput cols)
line=$(printf "%-${cols}s" "-")
line=${line// /-}
output=""


CRAN=$(grep -oP '(?<=namespace=).*' ./artifacts/vdu_config.ini | tail -n 1)
CURRENTSW=$(helm list -n $CRAN | grep aic-vdu- | awk '{print $9}' | sed 's/aic-vdu-//' | head -n 1)
CURRENTSWDATE=$(helm list -n $CRAN | grep aic-vdu-  | awk '{print  $4}' | head -n 1)





SEARCHDATE=""

#Loop through each URL and perform the search
for url in "${urls[@]}"; do
    result=$(curl "$url" -s | sed 's/<a//g' | awk '{print $1,$2,$3,$4}' | sed 's/href="//g' | sed 's/[<\/a>]//g' | sed 's/"/  /g' | sed 's/vduCNF00_//g' | sort -V | awk '{printf "\033[1;32m%s\033[0m\t \033[1;33m%s\033[0m \033[0m%s\033[0m\n", $1, $3, $4}' | grep "$CURRENTSW")

    # If a result is found, save it in the SEARCHDATE variable
    if [ -n "$result" ]; then
        SEARCHDATE="$result"
        break
    fi
done

ROLLBACK_BUILD=$(ls -1td /charts/vdu/aic-vdu-* 2>/dev/null \
    | sed -n '2p' \
    | sed -E 's:.*/aic-vdu-::')




latest_release=$(curl -s -H "Authorization: Bearer $TOKEN" \
"https://artifactory-mn-espoo3.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/" \
| grep -o 'vDUCNF[0-9]\+R[0-9]\+/' \
| sed 's:/$::' \
| sort -V \
| tail -n 1)



scripts=(
    "./20-delete-vdu.sh"
    "./21-create-vdu.sh"
)

arguments=(
    ""
    ""
)



echo -e "${RED}$line${NC}"
echo -e "${BLUE} _                                 _____            _     _                            _       "
echo "| |                               (____ \          | |   | |                          | |      "
echo "| |      ____ _____ _   _    _   _ _   \ \ _   _   | |   | |____   ____  ____ ____  __| | ____ "
echo "| |     / _  (___  ) | | |  | | | | |   | | | | |  | |   | |  _ \ / _  |/ ___) _  |/ _| |/ _  )"
echo "| |____( (_| |/ __/| |_| |   \ V /| |__/ /| |_| |  | |___| | |_| ( (_| | |  ( (_| ( (_| ( (/ / "
echo "|_______)__|_(_____)\__  |    \_/ |_____/  \____|   \______| |__/ \__| |_|   \__|_|\____|\____)"
echo "                   (____/                                  |_|   (_____|                       "
echo -e "${NC}"


echo -e "${RED}$line${NC}"

print_current_sw_info() {
  # Colors
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  NC='\033[0m'

  # Token + URLs
  TOKEN="cmVmdGtuOjAxOjE4MTE5MjkyOTU6WDQzTmRQRDlXeFhrNlpUN2xzTk1vR3R1SmU2"
  BASE_URL="https://artifactory-mn-espoo3.int.net.nokia.com/artifactory"

  # Get current SW and latest release
  CURRENTSW=$(helm list -n "$CRAN" | grep aic-vdu- | awk '{print $9}' | sed 's/aic-vdu-//' | head -n 1)

  # Daca nu exista niciun SW instalat, opre?te func?ia
  if [ -z "$CURRENTSW" ]; then
    echo -e "                 CURRENT SW: ${RED}NO VDU SOFTWARE INSTALLED${NC}"
    return
  fi

  latest_release=$(curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/mnp5g-central-public-local/System_Release/" \
    | grep -o 'vDUCNF[0-9]\+R[0-9]\+/' | sed 's:/$::' | sort -V | tail -n 1)

  # Function to check in a URL
  check_url_for_sw() {
    curl -s -H "Authorization: Bearer $TOKEN" "$1" \
    | grep "$CURRENTSW" \
    | sed -E 's/.*href="[^"]+">.*<\/a>[[:space:]]+([0-9]{2}-[A-Za-z]{3}-[0-9]{4})[[:space:]]+([0-9]{2}:[0-9]{2}).*/\1 \2/'
  }

  # Search in vDUCNF00
  SEARCHDATE=$(check_url_for_sw "$BASE_URL/mnp5g-central-public-local/System_Release/vDUCNF00/")

  # If not found, search in latest release
  if [ -z "$SEARCHDATE" ]; then
    SEARCHDATE=$(check_url_for_sw "$BASE_URL/mnp5g-central-public-local/System_Release/$latest_release/")
  fi

  # Final print
  if [ -z "$SEARCHDATE" ]; then
    echo -e "                 CURRENT SW: ${GREEN}$CURRENTSW${NC} ${RED} NOT FOUND IN ARTIFACTORY or OLDER THAN 14 DAYS${NC}"
  else
    echo -e "                 CURRENT SW: ${GREEN}$CURRENTSW${NC}  From ${YELLOW}$SEARCHDATE${NC}"
  fi
}

print_current_sw_info



echo -e "${RED}$line${NC}"
echo -e "${BLUE}Latest Builds......${NC}"

echo "Trunk:"
echo "$REG_00"
curl -s -H "Authorization: Bearer cmVmdGtuOjAxOjE4MTE5MjkyOTU6WDQzTmRQRDlXeFhrNlpUN2xzTk1vR3R1SmU2" \
https://artifactory-mn-espoo3.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/vDUCNF00/ \
| grep 'vDUCNF00_' \
| sed 's/<a href="/\n<a href="/g' \
| grep '^<a href="vDUCNF00_' \
| sed -E 's/.*href="vDUCNF00_([^/]*)\/">.*<\/a>[ \t]+([0-9]{2}-[A-Za-z]{3}-[0-9]{4})[ \t]+([0-9]{2}:[0-9]{2})/\1 \2 \3/' \
| sort -V \
| tail -n 3 \
| awk '{printf "\033[1;32m%s\033[0m\t \033[1;33m%s\033[0m \033[0m%s\033[0m\n", $1, $2, $3}'



echo ""
echo -e "$latest_release\033"
echo "$REG_OLDER"
curl -s -H "Authorization: Bearer cmVmdGtuOjAxOjE4MTE5MjkyOTU6WDQzTmRQRDlXeFhrNlpUN2xzTk1vR3R1SmU2" \
"https://artifactory-mn-espoo3.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/$latest_release/" \
| grep "${latest_release}_" \
| sed 's/<a href="/\n<a href="/g' \
| grep "^<a href=\"${latest_release}_" \
| sed -E "s/.*href=\"${latest_release}_([^/]*)\/\">.*<\/a>[[:space:]]+([0-9]{2}-[A-Za-z]{3}-[0-9]{4})[[:space:]]+([0-9]{2}:[0-9]{2})/\1 \2 \3/" \
| grep -E '^[0-9]{1,2}\.300\.[0-9]+' \
| sort -rV \
| head -n 3 \
| awk '{printf "\033[1;32m%s\033[0m\t \033[1;33m%s\033[0m \033[0m%s\033[0m\n", $1, $2, $3}'


ROLLBACK_BUILD=$(ls -td ./charts/vdu/aic-vdu-* | sed -n '2p' | sed 's|.*/aic-vdu-||')






echo "$output"
echo -e "${RED}$line${NC}"
echo -e "${BLUE}======================== vDU Deployment Menu ========================${NC}"
echo -e "${BLUE}<${NC}${GREEN}build version${NC}${BLUE}>${NC}   -> Upgrade to specific build (e.g. ${GREEN}25.300.553${NC})"
echo -e "${BLUE}redeploy${NC}          -> Delete & reinstall current build"
echo -e "${BLUE}reset${NC}             -> Delete namespace & SCF. Need upgrade after."
#echo -e "${BLUE}rollback${NC}          -> Revert to previous build ${GREEN}$ROLLBACK_BUILD${NC}"
echo -e "${RED}$line${NC}"
echo ""
echo "Build is :$REG_00_BUILD"
#NEW_VALUE=$REG_00_BUILD
NEW_VALUE=$(echo "$REG_00_BUILD" | sed -r 's/\x1B\[[0-9;]*[mK]//g')
echo "New value is :$NEW_VALUE"
#printf "${YELLOW}Enter one of the above options: ${NC}${NEW_VALUE}"
#read NEW_VALUE

function deploy() {
 # Compare Version
 VALUE1=$(awk -F "=" '/'$SECTION_VERSION'/,/^$/{if ($1~/'$VERSION'/){print $2}}' $FILE1 | tr -d ' ')
 VALUE2=$(awk -F "=" '/'$SECTION_VERSION'/,/^$/{if ($1~/'$VERSION'/){print $2}}' $FILE2 | tr -d ' ')


 # Change version
 if [ "$VALUE1" != "$VALUE2" ]; then
     sed -i "/^\[$SECTION_VERSION\]/,/^\[/ s/^\($VERSION\s*=\s*\).*\$/\1$VALUE2/" $FILE1
     echo "The value of $VERSION in $FILE1 has been updated to $VALUE2."
 fi

 # Change build in vdu_config.ini
 sed -i "/^\[$SECTION_BUILD\]/,/^\[/ s/^\($BUILD\s*=\s*\).*\$/\1$NEW_VALUE/" $FILE1
 #sed -i "/^\[$SECTION_BUILD\]/,/^\[/ s/^\($BUILD\s*=\s*\).*\$/\1$REG_00_BUILD/" $FILE1
 # Execute each script
 . ./10-vdu-l3call-test.sh
 echo -e "${RED}$line${NC}"
 echo -e "UPGRADE TO -> ${GREEN}$REG_00_BUILD${NC}"
 echo "./16-onboard-vdu.sh"
 echo -e "${RED}$line${NC}"
 ./16-onboard-vdu.sh
if [ $? -ne 0 ]; then
  echo -e "${RED}ERROR: BAD BUILD! Try something like this '0.300.30452' .${NC}"
  exit 1
fi
 echo -e "${RED}$line${NC}"
 echo "./20-delete-vdu.sh"
 echo -e "${RED}$line${NC}"
 ./20-delete-vdu.sh
 echo -e "${RED}$line${NC}"
 echo "./21-create-vdu.sh"
 echo -e "${RED}$line${NC}"
 ./21-create-vdu.sh
}


function redeploy() {
  . ./10-vdu-l3call-test.sh
  echo -e "${RED}$line${NC}"
  echo "REDEPLOY"
  echo "./20-delete-vdu.sh"
  echo -e "${RED}$line${NC}"
  ./20-delete-vdu.sh
  echo -e "${RED}$line${NC}"
  echo "./21-create-vdu.sh"
  echo -e "${RED}$line${NC}"
  ./21-create-vdu.sh
}

function reset_namespace() {
    echo -e "${RED}$line${NC}"
    echo "Resetting namespace..."
    echo -e "${RED}$line${NC}"

    # Executa verificarile de pre-reset
    . ./10-vdu-l3call-test.sh
    ./12-delete-vdu-namespace.sh
    echo -e "${RED}$line${NC}"
    ./13-create-vdu-namespace.sh
  echo -e "${RED}$line${NC}"
  echo "Need SW Upgrade now"
  echo -e "${RED}$line${NC}"
    cd ..
    cd ..
}

if [ "$NEW_VALUE" = "redeploy" ]; then
    redeploy
elif [ "$NEW_VALUE" = "reset" ]; then
    reset_namespace
elif [ "$NEW_VALUE" = "rollback" ]; then
    rollback  # asigura-te ca ai ?i func?ia rollback definita
else
    deploy
fi


CURRENTSW2=$(helm list -n "$CRAN" | grep aic-vdu- | awk '{print $9}' | sed 's/aic-vdu-//' | head -n 1)
echo "All scripts executed successfully."
echo "Curent vDU Build: $CURRENTSW2 "


echo -e "${RED}$line${NC}"
echo -e "${GREEN} _____    _____  ______  _______    _    _    _ "
echo -e "(____ \  / ___ \|  ___ \(_______)  | |  | |  | |"
echo -e " _   \ \| |   | | |   | |_____     | |  | |  | |"
echo -e "| |   | | |   | | |   | |  ___)    |_|  |_|  |_|"
echo -e "| |__/ /| |___| | |   | | |_____    _    _    _ "
echo -e "|_____/  \_____/|_|   |_|_______)  |_|  |_|  |_|"
echo -e "${NC} "
echo " "



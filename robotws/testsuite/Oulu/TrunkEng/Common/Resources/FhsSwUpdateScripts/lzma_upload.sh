#! /bin/bash

color_green="\e[0;32m"
color_red="\e[0;31m"
color_yellow="\e[0;103m"
color_reset="\e[00m"

warn() {
    echo -e ${color_red} $@ ${color_reset}
}

info() {
    echo -e ${color_red} $@ ${color_reset}
}

crccmd='python3 ./lzma_crc.py'
SSH_CMD_OUTPUT=""
SSH_TIMEOUT="15m" # Enough for all commands in this script.

run_command_via_ssh() {
    host=$FHS_IP
    command=$1
    discard_error=$2 # if absent, defautls to not true

    rm -f ~/.ssh/known_hosts
    echo -e "${color_yellow} [Running] ${color_green} ${command} ${color_reset}"
    # Sometimes sshpass gets stuck, so set a timeout here.
    SSH_CMD_OUTPUT=$(timeout $SSH_TIMEOUT sshpass -p oZPS0POrRieRtu ssh -o "StrictHostKeyChecking no" -q toor4nsn@$host $command 2>&1)
    ret=$?
    if [ $ret -ne 0 -a "$discard_error" != true ]; then
        echo "[Warning] Command \"$command\" on host $host failed with $ret. Output:"
        echo $SSH_CMD_OUTPUT
        return $ret
    fi
    return $ret
}

check_lzma_exist() {
    if [[ ! -f $LZMA_PATH ]]; then
        warn $LZMA_PATH does not exist on local machine!
        exit 2
    fi
}

check_swman_status() {
    run_command_via_ssh $fhs "ps -ef | grep swman::instance1 | grep -v grep"
    if [[ $? -ne 0 ]]; then
        warn "swman is not running."
        exit 2
    fi
}

upload_lzma_to_fhs() {

    lzma_on_fhs=/run/swman/$LZMA_NAME
    echo "Uploading $LZMA_PATH to FHS as $lzma_on_fhs ..."
    sshpass -p oZPS0POrRieRtu scp -o "StrictHostKeyChecking no" -q $LZMA_PATH toor4nsn@$FHS_IP:$lzma_on_fhs
    run_command_via_ssh "ls $lzma_on_fhs" || (
        warn "$lzma_on_fhs does not exist on FHS."
        exit 2
    )
}

calculate_lzma_versions() {

    # Get Current Version on FHS eg. FHS.11.R01
    run_command_via_ssh "SWmanShellCommand -i | awk '/runningBuildName/ {print \$3}'"
    LZMA_BUILD_NAME=$SSH_CMD_OUTPUT
    LZMA_BUILD_VERSION=$SSH_CMD_OUTPUT

    if [[ -z $LZMA_BUILD_NAME ]]; then
        warn "Cannot get runningBuildName on FHS."
        exit 2
    fi

    # Calculate crc and make version
    LZMA_CRC=$($crccmd $LZMA_PATH | tail -1)
    #LZMA_CRC="4015485605"
    #LZMA_CRC="4015485605"
    # Get LZMA file version
    LZMA_FILE_VERSION=$(echo $LZMA_NAME | sed "s/[^0-9]//g")
    LZMA_DATE=${LZMA_FILE_VERSION:0:8}
    LZMA_NO=${LZMA_FILE_VERSION: -1}
    LZMA_FILE_VERSION=$LZMA_DATE.$LZMA_NO

    info "New Lzma version is $LZMA_FILE_VERSION, crc=$LZMA_CRC, VERSION=$LZMA_BUILD_VERSION"
}

swman_save_lzma() {
    # Save eg. -s <fileName> <checksum> <fileVersion> <fileType> // <fileType> can be left empty
    # Sometimes the lzma file does exist at this step, or FHS swman process died, then this command will get stuck. WA: call sshpass with `timeout`.
    run_command_via_ssh "SWmanShellCommand -s /run/swman/$LZMA_NAME $LZMA_CRC $LZMA_FILE_VERSION \"\""
    # output:
    #SwSaveResp:
    #----------
    #fileName:      FHS-ID-SW_20201110143102.tar.lzma
    #fileVersion:   20201110.2
    #status:        OK
    #failureReason:
    echo $SSH_CMD_OUTPUT
    grep "status:.*OK" <<<$SSH_CMD_OUTPUT || (
        warn "Failed to save $LZMA_NAME"
        exit 2
    )

}

swman_active_lzma() {
    # Active, eg SWmanShellCommand -a <bldName> <bldVersion> <fileName> <fileVersion>
    run_command_via_ssh "SWmanShellCommand -a $LZMA_BUILD_NAME $LZMA_BUILD_VERSION $LZMA_NAME $LZMA_FILE_VERSION"
    # output:
    #SwActivateResp:
    #--------------
    #status:        OK
    #failureReason:
    echo $SSH_CMD_OUTPUT
    grep "status:.*OK" <<<$SSH_CMD_OUTPUT || (
        warn "Failed to activate $LZMA_NAME"
        exit 2
    )

    run_command_via_ssh "uboot_env -b set netboot=no"
}

install_lzma_to_FHS() {

    FHS_IP=$1

    check_lzma_exist

    check_swman_status

    upload_lzma_to_fhs

    calculate_lzma_versions

    swman_save_lzma

    swman_active_lzma

    # clean up debug stuff
    run_command_via_ssh "rm -f /configuration/appInhibitReboot"
    run_command_via_ssh "rm -f /ffs?/*.ipk"
}

if [ -z $1 ]; then
    echo Missing LZMA file
    exit 2
fi

LZMA_PATH=$1
LZMA_NAME=$(basename $1)
IP=192.168.1.131

install_lzma_to_FHS $IP

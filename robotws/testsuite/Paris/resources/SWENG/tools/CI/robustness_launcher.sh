#!/bin/bash

###############################################################################
#
# robustness_launcher.sh
#
# Description:
#    Script to be used to reserve an UTE testline, run tests and get results
#    back to the local VM. This release is specific for robustness tests.
#
###############################################################################

G_NO_PYTHON_UPDATE=${NO_PYTHON_UPDATE}
# set -xv

# Customizable parameters
#------------------------

G_ROBOT_DIR="/ebs/ca_psci5g/CRT_project/robotws5g"

G_CI_TOOLS_DIR="$G_ROBOT_DIR/testsuite/CRT/ParisSaclay/tools/CI"

# tool to be used for generating CI report
G_REPORT_TOOL="${G_CI_TOOLS_DIR}/crt_htmlReport.py"

# script to be run on testline
G_TEST_SCRIPT="crt_ute_run_test.sh"

# file to store all test output data
G_TEST_OUTPUT_FILE="crt_output.tar"

# directory to store data to be archived as artifacts in the job
G_ARCHIVE_DIR="archive"

G_TL_SSHKEY="./ute_id_rsa"

# values taken from Jenkins
# -------------------------

G_GNB_BUILD_ID=${CRT_GNB_BUILD_ID}
G_AP_BUILD_ID=${CRT_AP_BUILD_ID}
G_HIRE_SHERPA=${HIRE_A_SHERPA}
G_SOSREPORT_IFFAILED=${SOSREPORT_IFFAILED}
G_SHARK_TOOL=${CRT_SHARK_TOOL}
G_ROBOT_EXT_VAR=${CRT_ROBOT_EXTERNAL_VARIABLES}
G_TEST_BRANCH=${CRT_TEST_BRANCH}
G_PERIOD_CNT_ZOI=${NB_OF_PM_PERIOD_FOR_ZOI}

# test suite (related to G_ROBOT_DIR)
# G_TEST_SUITE="testsuite/RRM/ECE/UE_Call_Setup/5GC000636-D/5GC000636-D_ClassicalTestCases.robot"

G_TEST_SUITE=$(echo "${CRT_ROBOT_TEST_SUITE}" | sed -e "s/ //g")

G_TEST_CASE=$(echo "${CRT_TEST_CASE}" | sed -e "s/ //g")

G_UTE_TAGS="$CRT_UTE_TAGS" # ERROR when using space separator --> use comma separator

G_RESERVATION_ID=${CRT_RESERVATION_ID}

G_TESTLINE_IP=${CRT_TESTLINE_IP}

# use CRT_ARCHITECTURE while this parameter is not yet renamed to CRT_NETWORK_TYPE
G_NETWORK_TYPE=${CRT_ARCHITECTURE:-${CRT_NETWORK_TYPE:-NSA}}

G_UTE_API_TOKEN=${CRT_UTE_API_TOKEN}

G_DRYRUN=${CRT_DRYRUN}

G_FORCED_TAG=${CRT_FORCED_TAG}

G_VARIANT=${CRT_VARIANT}

API_TOKEN=${SCOUT_PERSONAL_API_TOKEN}

# fixed values for UTE request
# ----------------------------

G_UTE_BUILD_ID="None"

G_SYS_BUILD_ID="None"

G_TL_STATE="configured"

# testline reservation duration in minutes (max = 8h)
G_DURATION=480

# max time, in minutes, waiting to have a test line (12h)
G_WAIT_TIME=720

# For display
G_STEP=0

# set to 1 to reserve a TL only (no test will be run when the TL is available)
G_RESERV_TL_ONLY=0

# path to the file where to store the testline ID
G_OUTPUT_FILE=""

# list of comma separated tags to be used for reserving an UTE TL
G_TL_TAGS=""

# RAN Tag (will be determined dynamically)
G_RAN_TYPE=""

function Step()
{
    local __title=$1
    let G_STEP=G_STEP+1
    echo "=========================================================="
    echo "STEP $G_STEP : $__title"
    echo "=========================================================="
}


# -------------------------------------------------------------------
# Send mail to indicate end of test execution
# -------------------------------------------------------------------

function SendReport()
{
# set -xv
    local L_TEST_RESULT=$1
    local L_MSG_FILE="MailContent.$$.dat"
    local L_SENDER="AfCi@nokia.com"
    local L_JOB_NAME=$(echo "$JOB_NAME" | sed -e "s/.*\///g")

    Step    "SEND Report"
    
    if [ $L_TEST_RESULT -eq 0 ]
    then
        local L_MAIL_SUBJECT="Execution Summary: PASSED for $L_JOB_NAME (build #$BUILD_NUMBER)"
    else
        local L_MAIL_SUBJECT="Execution Summary: FAILED for $L_JOB_NAME (build #$BUILD_NUMBER)"
    fi

    # exit if mailing list is empty
    if [ -z "$CRT_MAILING_LIST" ]
    then
        echo "WARNING : mailing list is empty --> no mail sent"
        return 0
    fi

    echo "From: $L_SENDER"           > $L_MSG_FILE
    echo "To: $CRT_MAILING_LIST"     >> $L_MSG_FILE
    echo "Cc: "                      >> $L_MSG_FILE
    echo "Subject: $L_MAIL_SUBJECT"  >> $L_MSG_FILE
    echo "Content-type: text/html"   >> $L_MSG_FILE

    # replace "http" by "https" and "8080" by "443" in the URL
    # RDH Sept-2022: with the new Jenkins, this no more needed
    # local L_BUILD_URL=$(echo $BUILD_URL | sed "s/http/https/" | sed "s/8080/443/")

    echo -e "<p>" >> $L_MSG_FILE
    echo -e "Test execution has finished<br>" >> $L_MSG_FILE
    echo -e "Build URL = ${BUILD_URL}<br>" >> $L_MSG_FILE
    echo -e "</p>" >> $L_MSG_FILE

    # use Linux "sendmail" command to send mail
    echo "Sending email"
    cat $L_MSG_FILE | /usr/lib/sendmail -t -oi -f $L_SENDER
}


# -------------------------------------------------------------------
# Description
#     Run commands on rtemote VM
#        $1 : remote VM IP
#        $2 : remote VM user
#        $3 : remote VM password
#        $4 : file containg ssh key used for connecting to remote VM
#        $5 : commands to be run on the remote VM
# Return
#    Code returned by ssh command
# -------------------------------------------------------------------

function RunSshCmd()
{
# set -xv

    local L_TL_ADDRESS=$1
    local L_TL_USER=$2
    local L_TL_PASSWORD=$3
    local L_CMD=$4

    # currently, use of ssh key 
    ssh -o StrictHostKeyChecking=no -o CheckHostIP=no -i ${G_TL_SSHKEY} ${L_TL_USER}@${L_TL_ADDRESS} ${L_CMD}

    return $?
}


# -------------------------------------------------------------------
# Description
#     Transfer needed files to the TL
#         $1 : destination path on the TL
# Return
#     0 if all files could be tranferred to the TL
#     1 otherwise
# -------------------------------------------------------------------

function TransferFilesToTestline ()
{
    local L_DEST_PATH=$1

    # copy the test script (need to set w mode to avoid issue copying file to remote VM)
    chmod +wx $G_TEST_SCRIPT
    scp -o StrictHostKeyChecking=no -o CheckHostIP=no -i $G_TL_SSHKEY $G_TEST_SCRIPT ${UTE_TL_USER}@${UTE_TL_ADDRESS}:${L_DEST_PATH}

    if [ $? -ne 0 ]
    then
        echo "ERROR : test script $G_TEST_SCRIPT could not be transferred to the TL"
        return 1
    fi

    return 0
}


# set the G_GNB_BUILD_ID variable to the appropriated value
function SetGnbBuildId
{
set -xv

    local L_UTE_TOKEN=$1

    if [ -z "$G_GNB_BUILD_ID" ]
    then
        # if no GNB build ID provided from the GUI then set the default value
        echo "WARNING : no CRT_UTE_BUILD_ID provided --> latest UTE promoted load will be used to reserve a testline"
        G_GNB_BUILD_ID="None"
        return
    fi

    # get the latest promoted load from the associated branch
    # if a full build ID is provided then the same ID must be returned
    # (branch ID = first word of G_GNB_BUILD ID with "_" as separator)

    local L_OUTPUT_FILE="${WORKSPACE}/UteActiveLoad.$$.dat"
    python3  ./crt_ute_get_latest_active_load.py  \
                 -enbBuildId ${G_GNB_BUILD_ID}  \
                 -outputFile ${L_OUTPUT_FILE}  \
                 -uteToken ${L_UTE_TOKEN}

    # get the build ID stored in the ouput file
    . ${L_OUTPUT_FILE}

    if [ -z "${UTE_LATEST_ACTIVE_LOAD}" ] || [ "${UTE_LATEST_ACTIVE_LOAD}" == "None" ]
    then
        echo "ERROR : could not find the requested build --> exit"
        exit 1
    fi

    # if the retrieved BUILD ID is different from the GUI input parameter then add a record to the stat
    # (this is the case when user does not provide a full BUILD ID and the latest promoted build is taken
    #  from UTE using the input BUILD ID as regex)

    if [ -z "${G_RESERVATION_ID}" ] && [ "${G_GNB_BUILD_ID}" != "${UTE_LATEST_ACTIVE_LOAD}" ]
    then
        # log only for a "real reservation"
        local L_STAT_FILEPATH="/home/ca_psci5g/$(basename $(pwd))/STAT/BranchUsage.dat"
        local L_DATA="${BUILD_USER_ID}  ${G_GNB_BUILD_ID}  ${UTE_LATEST_ACTIVE_LOAD}"
        python3  ./crt_ute_append_to_file.py  -filepath "${L_STAT_FILEPATH}"  -data "${L_DATA}"
    fi

    G_GNB_BUILD_ID=${UTE_LATEST_ACTIVE_LOAD}
}


# Testline reservation - to be used with old topologies without variant
function ReserveUteTestline()
{
# set -xv
    echo "TESTLINE RESERVATION IS ON GOING..."
    local L_TMP_FILE="/tmp/crt_data.$$.tmp"

    local L_RESERVATION_ID_OPTION=""

    [ -n "${G_RESERVATION_ID}" ] && L_RESERVATION_ID_OPTION="-reservId ${G_RESERVATION_ID}"

    if [ -z "${G_UTE_API_TOKEN}" ]
    then
        # no token provided in the GUI --> trying to get the token from user home directory
        local L_TOKEN_FILE="/home/${BUILD_USER_ID}/.crtci/UteApiToken.dat"
        if [ ! -f $L_TOKEN_FILE ]
        then
            echo "ERROR : missing of CRT_UTE_API_TOKEN --> exit"
            exit 1
        else
            G_UTE_API_TOKEN=$(cat $L_TOKEN_FILE)
        fi
    fi

    local L_UTE_TOKEN_OPTION="-uteToken ${G_UTE_API_TOKEN}"

    # init the log file
    # :> ${G_CI_DATA_PATH}

    # Manage parameter CRT_UTE_TOPOLOGY

    local L_TL_TYPE=""

    if [ -n "$CRT_UTE_TOPOLOGY" ]
    then
        L_TL_TYPE=$CRT_UTE_TOPOLOGY
        if [ -n "$G_VARIANT" ]
        then
            echo "Requested Topology is: $G_VARIANT"
#            G_VARIANT="${G_VARIANT//VARIANT_}"
#            echo "Real Topology is: $G_VARIANT"
            if [[ ${G_UTE_TAGS} == *"TOOLS_PROFILE"* ]]
            then
                echo "A SPECIFIC TOOLS_PROFILE WAS REQUESTED IN CRT_UTE_TAGS"
                G_TL_TAGS="${G_VARIANT},RAN_5G"
            else
                echo "DEFAULT TOOLS_PROFILE_TTI_LEGACY WILL BE USED"
                G_TL_TAGS="${G_VARIANT},RAN_5G,TOOLS_PROFILE_TTI_LEGACY"
            fi
        else
            echo "Topology without variant"
            # get the 5G_RAN_xxx flag (required by UTE) given that the provided topology suffix is FDD/TDD
            G_RAN_TYPE=$(echo $L_TL_TYPE | awk -F_ '{print $NF}')
            G_TL_TAGS="5G_RAN_${G_RAN_TYPE}"
            # RDH 2023.01.30 - ORAN case:
            if [ "$G_RAN_TYPE" == "ORAN" ]
            then
                echo "ORAN TL is requested => add RAN_5G in tags list"
                G_TL_TAGS="${G_TL_TAGS},RAN_5G"
            fi
        fi
    else
        echo "ERROR : MISSING OF CRT_UTE_TOPOLOGY --> EXIT"
        exit 1
    fi

    [ -n "$G_UTE_TAGS" ] && G_TL_TAGS="${G_TL_TAGS},${G_UTE_TAGS}"

    echo L_TL_TYPE=$L_TL_TYPE

    if [ "$L_TL_TYPE" == "CLOUD_5G_I_[BO][BO]_AP_[KLLL]_SANSA_FS_CPRI_CMWV_FDD" ] || 
       [ "$L_TL_TYPE" == "CLOUD_5G_I_[BO][BO]_AP_[KLLL]_SANSA_L1B_CPRI_CMWV_FDD" ]
    then
        echo "Special treatment for multi GNB TL: wait 23h for reservation "
        G_WAIT_TIME=1380
    fi

    # RDH 08-oct-2022 :
    # A full VRAN2 loadname is like this: vDUCNF_0.300.8331
    # A full Classical loadname is like this: SBTS22R4_ENB_0000_000606_000006
    # The length of a full classical loadname is greater than 28 characters
    # If the tester required a full loadname, we take it as it is. 
    # Otherwise, tester gives a branch name: we will use it to search the latest promoted load.
    local L_VRAN2_LOAD=$(echo $G_GNB_BUILD_ID | awk -F_ '{print $1}')
    local L_CLASS_LOAD=$(echo $G_GNB_BUILD_ID | awk -F_ '{print $2}')
    local L_PARAM_LENGTH=${#G_GNB_BUILD_ID}
    if [ "$L_VRAN2_LOAD" == "vDUCNF" ] && (( "$L_PARAM_LENGTH" >= "17" ))
    then
        echo "The following VRAN2 load will be used: $G_GNB_BUILD_ID"
    elif [ "$L_CLASS_LOAD" == "ENB" ] && (( "$L_PARAM_LENGTH" >= "28" ))
    then
        echo "The following SBTS load will be used: $G_GNB_BUILD_ID"
     else
        echo "The $G_GNB_BUILD_ID branch name will be used to get the latest promoted load"
        SetGnbBuildId ${G_UTE_API_TOKEN}
    fi

    # remove existing output file
    # (to avoid error in case if it's already exist, this may happen when the process number is re-used again)
    rm -f ${L_TMP_FILE}

    # reserve an UTE testline, wait until it's ready and return useful information :
    # in the output file (IP of the VM, login, password)
    python3 ./crt_ute_reserve_tl.py \
            -tlType $L_TL_TYPE \
            -tlState $G_TL_STATE \
            -tlTags  $G_TL_TAGS \
            -gnbBuildId $G_GNB_BUILD_ID \
            -uteBuildId $G_UTE_BUILD_ID \
            -sysBuildId $G_SYS_BUILD_ID \
            -duration $G_DURATION \
            -outputFile $L_TMP_FILE \
            -waitTime $G_WAIT_TIME \
            ${L_UTE_TOKEN_OPTION} \
            ${L_RESERVATION_ID_OPTION}
    # If the reservation fails:
    if [ $? -ne 0 ]
    then
        echo "ERROR : test line reservation was failed --> exit"
        exit 1
    else
         echo "Keep the test line alive"
         local L_SCRIPT_DIR=$(dirname $(realpath $0))
         ${L_SCRIPT_DIR}/ExtendDuration.sh $UTE_TL_ID  $G_UTE_API_TOKEN > /tmp/ExtendDuration.$$.log 2>&1 &
    fi

    # Reservation is OK: we display the TL info:
    echo -e "\nOutput file content:"
    cat $L_TMP_FILE

    # WA - replace the provided password by arbitrary value to bypass issue with password containing special chars
    sed -i 's/UTE_TL_PASSWORD=.*/UTE_TL_PASSWORD=ute/' $L_TMP_FILE

    # get information from the output file
    source $L_TMP_FILE

    echo -e "\nDefined variables:"
    echo "UTE_TL_SITE = $UTE_TL_SITE"
    echo "UTE_TL_NAME = $UTE_TL_NAME"
    echo "UTE_TL_ADDRESS = $UTE_TL_ADDRESS"
    echo "UTE_TL_USER = $UTE_TL_USER"
    echo "UTE_TL_PASSWORD = $UTE_TL_PASSWORD"
    echo "UTE_TL_ID = $UTE_TL_ID"
    echo "UTE_TL_UUID = $UTE_TL_UUID"

    # update the GNB_BUILD_ID with the GNB load ID provided by UTE
    # (the ID provided by UTE takes over the ID provided by the GUI)
    echo "UTE_TL_GNB_ID = $UTE_TL_GNB_ID"
    G_GNB_BUILD_ID=$UTE_TL_GNB_ID

    # remove temporary files
    # rm $L_TMP_FILE

    # get the current AP version, on the test line, which will be defined by "UTE_AP_VERSION" variable
    GetCurrentApVersion

    # the returned AP version does not have "5G_" prefix --> add it
    local L_CURRENT_AP_VERSION="5G_${UTE_AP_VERSION}"

    echo "Requested AP version = $G_AP_BUILD_ID, current AP version = ${L_CURRENT_AP_VERSION}"
 
    # If an AP load is required and it's different from the current AP version then install it
    if [ -n "${G_AP_BUILD_ID}" ] && [ "${G_AP_BUILD_ID}" != "${L_CURRENT_AP_VERSION}" ]
    then
        echo "===== A P    L O A D    T O    B E    I N S T A L L E D : $G_AP_BUILD_ID ===== "
        # agent-sim version: 
        # InstallAirPhoneLoad $CRT_UTE_TOPOLOGY $G_GNB_BUILD_ID $G_AP_BUILD_ID $G_RAN_TYPE
        InstallAirPhoneLoad $CRT_UTE_TOPOLOGY $CRT_VARIANT $G_GNB_BUILD_ID $G_AP_BUILD_ID $G_RAN_TYPE
        local L_RESULT=$?
        if [ $L_RESULT -ne 0 ]
        then
            exit 1
        fi
    fi
}



# Function to retrieve the AP version currently installed on the TL
function GetCurrentApVersion()
{
set -xv

    # Copy the script, which can be used to get the AP version, to the test line VM

    local L_SCRIPT_NAME="crt_ute_get_ap_version.sh"

    local L_SRC_FILE="$(pwd)/${L_SCRIPT_NAME}"

    local L_DEST_DIR="/home/ute"

    local L_OUTPUT_FILE="/tmp/CurrentApVersion.$$.dat"
    
    scp -o StrictHostKeyChecking=no -o CheckHostIP=no -i ${G_TL_SSHKEY} ${L_SRC_FILE} ${UTE_TL_USER}@${UTE_TL_ADDRESS}:${L_DEST_DIR}

    if [ $? -ne 0 ]
    then
        echo "ERROR : failure to transfer ${L_SCRIPT_NAME} to the test line VM --> exit !"
        exit 1
    fi

    # run the script to retrieve the AP version then save itin  the output file

    local L_REMOTE_SCRIPT="${L_DEST_DIR}/${L_SCRIPT_NAME}"

    local L_CMD="chmod 777 ${L_REMOTE_SCRIPT}; ${L_REMOTE_SCRIPT} ${L_OUTPUT_FILE}"

    RunSshCmd "$UTE_TL_ADDRESS" "$UTE_TL_USER" "$UTE_TL_PASSWORD" "$L_CMD"

    # copy the output file to the local VM
    scp -o StrictHostKeyChecking=no -o CheckHostIP=no -i $G_TL_SSHKEY ${UTE_TL_USER}@${UTE_TL_ADDRESS}:${L_OUTPUT_FILE}  .

    # set the variables defined in the file ("UTE_AP_VERSION")

    local L_LOCAL_OUTPUT_FILE=./$(basename ${L_OUTPUT_FILE})

    . ${L_LOCAL_OUTPUT_FILE}
}

        InstallAirPhoneLoad $CRT_UTE_TOPOLOGY $CRT_VARIANT $G_GNB_BUILD_ID $G_AP_BUILD_ID $G_RAN_TYPE


function InstallAirPhoneLoad()
{
# set -xv
# goal: create this command:
#       agentctl exec --mode init --label ${L_TOPOLOGY} --variant ${L_VARIANT} --sm-build ${L_GNB_BUILD_ID} --airphone-build ${L_AP_BUILD_ID} --required-state configured --output /home/ute/testline_init_results

    L_TOPOLOGY=$1
    L_VARIANT=$2
    L_GNB_BUILD_ID=$3
    L_AP_BUILD_ID=$4
    L_DUPLEX_TYPE=$5

    # Prepare the command to install AP Load:

    local L_TMP_DUPLEX_TYPE=$(echo "$L_DUPLEX_TYPE" | tr '[:upper:]' '[:lower:]')
    
    # need to remove the "CONFIGS_" prefix from the tags
    local L_TMP_UTE_TAGS=$(echo ${G_UTE_TAGS} | sed "s/CONFIGS_//g")

    local L_CUSTOM_CONFIG_OPTION=""
    [ -n "${L_TMP_UTE_TAGS}" ] && L_CUSTOM_CONFIG_OPTION="--custom_config ${L_TMP_UTE_TAGS}"
    
#    local L_CMD="source /opt/ute/agent_env/bin/activate && \
#                agent-sim init -l ${L_TOPOLOGY} -a ${L_AP_BUILD_ID} -s configured --duplex=${L_TMP_DUPLEX_TYPE} ${L_CUSTOM_CONFIG_OPTION}"

    # need to remove the "CONFIGS_" prefix from the tags
    L_VARIANT=$(echo "${L_VARIANT}" | sed -e "s/VARIANT_//g")
    
    # command for agentCTL:
    local L_CMD="agentctl exec --mode init --label ${L_TOPOLOGY} --variant ${L_VARIANT} --sm-build ${L_GNB_BUILD_ID} --airphone-build ${L_AP_BUILD_ID} --required-state configured --output /home/ute/testline_init_results"

    echo -e "\nDefined variables:"
    echo "TOPOLOGY = $L_TOPOLOGY"
    echo "VARIANT = $L_VARIANT"
    echo "GNB BUILD ID = $L_GNB_BUILD_ID"
    echo "AP BUILD ID = $L_AP_BUILD_ID"
    echo "DUPLEX TYPE = $L_TMP_DUPLEX_TYPE"
    echo "TL ADDRESS = $UTE_TL_ADDRESS"
    echo "TL USER = $UTE_TL_USER"
    echo "TL PWD = $UTE_TL_PASSWORD"

    # Launch the command :
    echo "SPECIFIC AIRPHONE LOAD INSTALLATION IN PROGRESS... "
    RunSshCmd "$UTE_TL_ADDRESS" "$UTE_TL_USER" "$UTE_TL_PASSWORD" "$L_CMD"

    if [ $? -ne 0 ]
    then
        echo "=============================================="
        echo ">> ERROR - failure during AP load installation"
        echo "=============================================="
        return 1
    else
        echo "=============================================="
        echo ">> AP Load Installation : OK"
        echo "=============================================="
        return 0
    fi
}



function GetTestlineName()
{
# set -xv

    local L_TESTLINE_IP=$1

    local L_CMD="hostname | sed \"s/-/_/g\""

    local L_TESTLINE_NAME=$(RunSshCmd $UTE_TL_ADDRESS  $UTE_TL_USER  $UTE_TL_PASSWORD  "$L_CMD")

    echo $L_TESTLINE_NAME

    return 0
}



function StartTest()
{
set -xv

    local L_WORKING_DIR="/home/ute"

    G_GNB_BUILD_ID=$UTE_TL_GNB_ID

    # copy all files, needed for running tests, to the TL
    TransferFilesToTestline "$L_WORKING_DIR"

    if [ $? -ne 0 ]
    then
        echo "ERROR : files transfer to testline was failed --> exit"
        exit 1
    fi

    # set test case option if needed
    local L_TEST_CASE_OPTION=""
    [ -n "$G_TEST_CASE" ] && L_TEST_CASE_OPTION="-testCase $G_TEST_CASE"

    local L_TEST_BRANCH_OPTION=""
    [ -n "${G_TEST_BRANCH}" ] && L_TEST_BRANCH_OPTION="-testBranch ${G_TEST_BRANCH}"

    local L_NETWORK_TYPE_OPTION=""
    [ -n "${G_NETWORK_TYPE}" ] && L_NETWORK_TYPE_OPTION="-networkType ${G_NETWORK_TYPE}"

    local L_ROBOT_EXT_VAR=""
    if [ -n "${G_ROBOT_EXT_VAR}" ]
    then
        L_ROBOT_EXT_VAR="${G_ROBOT_EXT_VAR}"
    fi

    local L_SHERPA_OPTION=""
    if [ -n "${G_HIRE_SHERPA}" ]
    then
        local L_TMP_VAL=$(echo ${G_HIRE_SHERPA} | tr '[:lower:]' '[:upper:]')
        if [ "${L_TMP_VAL}" == "TRUE" ]
        then
            L_SHERPA_OPTION="-hireSherpa True"
        fi
    fi
    local L_SOSREPORT_IFFAILED=""
    if [ -n "${G_SOSREPORT_IFFAILED}" ]
    then
        local L_TMP_VAL=$(echo ${G_SOSREPORT_IFFAILED} | tr '[:lower:]' '[:upper:]')
        if [ "${L_TMP_VAL}" == "TRUE" ]
        then
            L_SOSREPORT_IFFAILED="-sosReport True"
        fi
    fi

    # RDH Aug-2022: MC_SHARK est obligatoire
    # local L_SHARK_TOOL="-sharkTool LUA_SHARK"
    # if [ -n "${G_SHARK_TOOL}" ]
    # then
    #     L_SHARK_TOOL="-sharkTool ${G_SHARK_TOOL}"
    # fi
    local L_SHARK_TOOL="-sharkTool MC_SHARK"

    local L_DRYRUN_OPTION=""
    [ "${G_DRYRUN}" == "true" ] && L_DRYRUN_OPTION="-dryrun"

    local L_FORCE_TAG_OPTION=""
    [ "${G_FORCED_TAG}" == "true" ] && L_FORCED_TAG_OPTION="-forcedTag"

    local L_LOCAL_TESTLINE_OPTION=""
    [ "${L_LOCAl_TESTLINE}" == "true" ] && L_LOCAl_TESTLINE_OPTION="-localTl"

    local L_UTE_TOPOLOGY_OPTION=""
    # RDH - Variant evolution:
    # [ -n "${CRT_UTE_TOPOLOGY}" ] && L_UTE_TOPOLOGY_OPTION="-tlTopology ${CRT_UTE_TOPOLOGY}"
    if [ -n "$CRT_UTE_TOPOLOGY" ]
    then
        if [ -n "$G_VARIANT" ]
        then
            echo "Reservation done with $CRT_UTE_TOPOLOGY and $G_VARIANT"
            L_VARIANT=$(echo "${G_VARIANT}" | sed -e "s/VARIANT_//g")
            CRT_UTE_TOPOLOGY=${CRT_UTE_TOPOLOGY}_${L_VARIANT}
            echo "Full Topology name is now: $CRT_UTE_TOPOLOGY"
        fi
        L_UTE_TOPOLOGY_OPTION="-tlTopology ${CRT_UTE_TOPOLOGY}"
    fi
    
    ## extend TL reservation time (script to be run in background)
    ## (Need to extend the reservation time to avoid TL to be released after 4h which is the iniial 
    ##  reservation time. If this is not done, tests taking more than 4h cannot work correctly)

    # if [ -z "${CRT_POSTBUILD_ACTION}" ]
    # then
         echo "Keep the test line alive"

         # ADT - 2022/09/21 - use L_SCRIPT_DIR instead of "${WORKSPACE}/CrtUteCiScripts_2_vran20/" which was a bad path
         # ${WORKSPACE}/CrtUteCiScripts_2/ExtendDuration.sh $UTE_TL_ID  $G_UTE_API_TOKEN > /tmp/ExtendDuration.$$.log 2>&1 &
         local L_SCRIPT_DIR=$(dirname $(realpath $0))
         ${L_SCRIPT_DIR}/ExtendDuration.sh $UTE_TL_ID  $G_UTE_API_TOKEN > /tmp/ExtendDuration.$$.log 2>&1 &
    # fi

    # run tests on the TL
    local L_CMD="${L_WORKING_DIR}/${G_TEST_SCRIPT} -tlSite ${UTE_TL_SITE} \
                                                -tlName ${UTE_TL_NAME} \
                                                -tlAddress ${UTE_TL_ADDRESS} \
                                                -tlUser ${UTE_TL_USER} \
                                                -tlPassword ${UTE_TL_PASSWORD} \
                                                ${L_TEST_BRANCH_OPTION} \
                                                -testSuite ${G_TEST_SUITE} \
                                                ${L_TEST_CASE_OPTION} \
                                                ${L_NETWORK_TYPE_OPTION} \
                                                -gnbBuildId ${G_GNB_BUILD_ID} \
                                                ${L_SHERPA_OPTION} \
                                                ${L_SOSREPORT_IFFAILED} \
                                                ${L_SHARK_TOOL} \
                                                ${L_DRYRUN_OPTION} \
                                                ${L_FORCED_TAG_OPTION} \
                                                ${L_LOCAL_TESTLINE_OPTION} \
                                                ${L_UTE_TOPOLOGY_OPTION}
                                                ${L_ROBOT_EXT_VAR}"

    RunSshCmd $UTE_TL_ADDRESS  $UTE_TL_USER  $UTE_TL_PASSWORD  "export NB_OF_PM_PERIOD_FOR_ZOI=${G_PERIOD_CNT_ZOI};export SCOUT_API_TOKEN=${API_TOKEN};export NO_PYTHON_UPDATE=${G_NO_PYTHON_UPDATE};$L_CMD"
    local L_TEST_RESULT=$?
    echo ">> L_TEST_RESULT=$L_TEST_RESULT"

    # get the test output tar file
    scp -o StrictHostKeyChecking=no -o CheckHostIP=no -i $G_TL_SSHKEY ${UTE_TL_USER}@${UTE_TL_ADDRESS}:${L_WORKING_DIR}/$G_TEST_OUTPUT_FILE  .

    # when running on Jenkins, save data for archiving
    if [ -n "$WORKSPACE" ]
    then
            # local L_ARCHIVE_DIR="$WORKSPACE/${G_ARCHIVE_DIR}"
            # mkdir -p "${L_ARCHIVE_DIR}" 

            # copy the tar file in the archive directory
            cp $G_TEST_OUTPUT_FILE  ${L_ARCHIVE_DIR}

            # setup data for archiving
            (
                cd ${L_ARCHIVE_DIR}

                # extract data from the tar file excluding "Logs" directory
                tar xvfz $G_TEST_OUTPUT_FILE --exclude=Logs

                #  get the number of test suites that have been run (equal to number of sub-directories except for ".")
                L_NB_TEST_SUITE=$(find . -maxdepth 1 -type d | grep -v "\.$" | wc -l)

                # if there is only 1 test suite executed then move all test data to the archive dir
                if [ ${L_NB_TEST_SUITE} -eq 1 ]
                then
                   L_DIR=$(find . -maxdepth 1 -type d | grep -v "\.$")
                   mv ${L_DIR}/* .
                   rm -r ${L_DIR}
                fi
            )
    fi

    return $L_TEST_RESULT
}



# execute post build action (reslease or keep the tesline)
function ExecutePostBuildAction ()
{
set -xv

    local L_ACTION=$1

    if [ "${L_ACTION}" == "KEEP_TL" ]
    then
        ## start the KEEP_ALIVE job if no build has been run for the same TL
        if [ -n "${UTE_TL_UUID}" ]
        then
            # check if a KEEP_ALIVE build has been run for this TL

            local L_BASE_DIR="/home/ca_psci5g/.CrtLockData"
            [ ! -d ${L_BASE_DIR} ] && mkdir -p ${L_BASE_DIR}

            local L_LOCK_DIR="${L_BASE_DIR}/KUTA.${UTE_TL_UUID}.lock"
            mkdir $L_LOCK_DIR > /dev/null 2>&1
            if [ $? -ne 0 ]
            then
                echo "There is already a KEEP_UTE_TL_ALIVE build running for this test line"
                return 0
            fi
            echo "Start KEEP_UTE_TL_ALIVE job for testline ${UTE_TL_UUID}"

            # It's not possible to directly use the JENKINS_URL variable as the server name is
            # replaced by the IP address and, in this case, the curl command cannot work
            # Example of JENKINS_URL as provided by Jenkins
            #    http://10.183.129.251:8080

            # RDH Sept-2022: the new Jenkins configuration allows now to use the JENKINS_URL variable
            # local L_JENKINS_URL="https://5g-nps-jenkins.dyn.nesc.nokia.net"
            # local L_JENKINS_URL="https://jenkins-nps.ps5gl2.es-si-os-ohn-70.k8s.dyn.nesc.nokia.net"
            local L_JOB_URL="${JENKINS_URL}/job/CRT_CI/job/UTE_MIGRATION/job/TOOLS/job/KEEP_UTE_TL_ALIVE/buildWithParameters?"
            local L_JOB_TOKEN="AutTok001"
            local L_JOB_PARAM="token=${L_JOB_TOKEN}&CRT_RESERVATION_ID=${UTE_TL_UUID}&CRT_UTE_API_TOKEN=${G_UTE_API_TOKEN}"
            local L_JOB_BUILD="${L_JOB_URL}${L_JOB_PARAM}"
            curl --insecure -I ${L_JOB_BUILD}
        fi
    elif [ "${L_ACTION}" == "RELEASE_TL" ]
    then
        if [ -n "${UTE_TL_UUID}" ]
        then
            # release the TL
            echo "Release testline ${UTE_TL_UUID}"
            ./ReleaseTestline.sh  $UTE_TL_UUID  $G_UTE_API_TOKEN
        fi
    fi
}



# -------------------------------------------------------------------
# MAIN function
# -------------------------------------------------------------------

function main()
{
# set -xv

    # variable to indicate if the TL is local or UTE (default = UTE TL)
    local L_LOCAL_TESTLINE=false

    echo "Test started by ${BUILD_USER} SCOUT_API_TOKEN=${API_TOKEN}"
    echo "ZOI duration for robustness: ${G_PERIOD_CNT_ZOI}"

    # if no test suite provided then reserve the testline only

    if [ -z "${G_TEST_SUITE}" ]
    then
        echo "No CRT_ROBOT_TEST_SUITE provided --> reserve only a testline"
        G_RESERV_TL_ONLY=1
    fi

    # need to create archive dir to avoid error trying to archive data from inexisting dir
    local L_ARCHIVE_DIR="$WORKSPACE/${G_ARCHIVE_DIR}"
    mkdir -p "${L_ARCHIVE_DIR}"

    if [ -n "$G_TESTLINE_IP" ]
    then
        # If testline IP is provided then it has higher priority then the reservation ID

        L_LOCAL_TESTLINE=true

        UTE_TL_SITE="Paris-Saclay"
        UTE_TL_ADDRESS=${G_TESTLINE_IP}
        UTE_TL_USER="ute"
        UTE_TL_PASSWORD="ute"
        UTE_TL_NAME=$(GetTestlineName ${G_TESTLINE_IP})
        UTE_TL_ID="Undefined"

        # set BUILD_ID in case if it is not provided when using testline IP
        [ -n "${G_GNB_BUILD_ID}" ] && UTE_TL_GNB_ID=${G_GNB_BUILD_ID} || UTE_TL_GNB_ID="Undefined"

        echo -e "\nDefined variables:"
        echo "UTE_TL_SITE = $UTE_TL_SITE"
        echo "UTE_TL_NAME = $UTE_TL_NAME"
        echo "UTE_TL_ADDRESS = $UTE_TL_ADDRESS"
        echo "UTE_TL_USER = $UTE_TL_USER"
        echo "UTE_TL_PASSWORD = $UTE_TL_PASSWORD"
        echo "UTE_TL_ID = $UTE_TL_ID"
        echo "UTE_TL_GNB_ID = $UTE_TL_GNB_ID"
    else
        ReserveUteTestline
    fi


    if [ ${G_RESERV_TL_ONLY} -eq 1 ]
    then
        # run a fake test to generate logs files required by "Robot Framework Test Result" plugin
        local L_TEST_PATH="$(pwd)/ROBOT/welcome.robot"
        local L_DEST_PATH="/home/ute"
        chmod +w ${L_TEST_PATH}
        scp -o StrictHostKeyChecking=no -o CheckHostIP=no -i ${G_TL_SSHKEY} ${L_TEST_PATH} ${UTE_TL_USER}@${UTE_TL_ADDRESS}:${L_DEST_PATH}
        G_TEST_SUITE="${L_DEST_PATH}/$(basename ${L_TEST_PATH})"
        G_TEST_CASE=""
        # set force tag to avoid execution error (as there is no tag specified in the test)
        G_FORCED_TAG="true"
    fi

    StartTest

    local L_TEST_RESULT=$?

    # execute post build action (reslease or keep the tesline)
    ExecutePostBuildAction ${CRT_POSTBUILD_ACTION}

    # send mail
    SendReport  $L_TEST_RESULT

    # exit with test result
    return $L_TEST_RESULT

}


main

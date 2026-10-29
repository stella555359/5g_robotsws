#!/bin/bash

# ./crt_ute_run_test.sh
#       -tlSite      Wroclaw
#       -tlName      2_16_UTE5GCLASSICAL1691
#       -tlAddress   10.42.99.147
#       -tlUser      ute
#       -tlPassword  6d6d42a7
#       -wtsCfgDir   /tmp/myWtsCfgDir
#       -testSuite   testsuite/RRM/ECE/UE_Call_Setup/5GC000636-D/5GC000636-D_ClassicalTestCases.robot

# set -xv

# Customizable parameters
#------------------------

G_HOME_DIR="/home/ute"

# root directory = the parent directory of "robotws5g"
# G_ROOT_DIR="${G_HOME_DIR}/CrtRoot"
G_ROOT_DIR="$(pwd)/../../../../../../.."

# "Auto5G" cannot be used as it's not a git dir (missing of git config data)
G_ROBOT_DIR="${G_ROOT_DIR}/robotws"

# directory used for storing test output (*.log, *.html, ...)
G_LOGS_DIR="${G_ROOT_DIR}/logs/CrtTest_$(date '+%Y_%m_%d-%H_%M')"

# file to store all test output data
G_TAR_FILE="CrtTestOutput.tar"

# For display
G_STEP=0

# default = use python version provided by UTE
G_USE_PYTHON3=0

# default = copy and patch the TL "__init__.py" file
G_KEEP_INIT=0

# default = copy Tnd patch the TL "__init__.py" file
G_CP_INIT_ONLY=0

# default = run test in real mode
G_DRY_RUN=0

# set to 1 to install SHERPA packages on the TL VM
G_INSTALL_SHERPA=0

# set to 1 to activate Sherpa in the test suite
G_HIRE_SHERPA=0

# set to 0 to deactivate SoSReport in the test suite
G_SOS_REPORT=1



function Step()
{
    local __title=$1

    let G_STEP=G_STEP+1

    echo "=========================================================="
    echo "STEP $G_STEP : $__title"
    echo "=========================================================="
}



# -------------------------------------------------------------------
# Configure needed IP addresses
# -------------------------------------------------------------------

function  AddEth3Addr ()
{

    sudo ip addr add 10.0.1.121 dev eth3
    sudo ip addr add 10.0.1.131 dev eth3
    sudo ip addr add 10.0.1.132 dev eth3
    sudo ip addr add 10.0.1.133 dev eth3
    sudo ip addr add 10.0.1.134 dev eth3
    sudo ip addr add 10.0.1.135 dev eth3
    sudo ip addr add 10.0.1.136 dev eth3
    sudo ip addr add 10.0.1.137 dev eth3
    sudo ip addr add 10.0.1.138 dev eth3
}



# -------------------------------------------------------------------
# Patching config files
# -------------------------------------------------------------------

function PatchingFiles ()
{
set -xv

    local L_SRC_FILE
    local L_DST_DIR


    # Copy WTS config files if required
    if [ -n "$G_WTS_CFG_DIR" ]
    then
        L_SRC_FILE="${G_WTS_CFG_DIR}/basic_wts_step2.cfg"
        L_DST_DIR="/opt/iphy/latest"

        echo "Copying $L_SRC_FILE to $L_DST_DIR"
        cp ${L_SRC_FILE} ${L_DST_DIR}

        # example of line containing XML file name
        # "set_uec file=AirPhoneConfig.xml id=1 ip=$DAEMON_IP:$DAEMON_PORT peer=$DAEMON_IP:2152 ..."
        # -->  get the substring starting right after "file=" then get the 1st word

        local L_XML_CFG_LINE=$(egrep "^set_uec" $L_SRC_FILE)
        local L_XML_FILE=$(echo ${L_XML_CFG_LINE#*file=} | cut -d" " -f1)

        L_SRC_FILE="${G_WTS_CFG_DIR}/${L_XML_FILE}"
        L_DST_DIR="/opt/iphy/latest"

        echo "Copying $L_SRC_FILE to $L_DST_DIR"
        cp ${L_SRC_FILE} ${L_DST_DIR}
    fi

    # "-keepInit" option is provided --> no more thing to do
    [ $G_KEEP_INIT -eq 1 ] && return

    # copy the testline configuration ( __init__.py) from the official directory to the working dir

    echo "Copying $G_TL_NAME configuration directory"

    local L_OFFICIAL_TL_DIR="/home/ute/testline_configuration/${G_TL_NAME}"

    if [ ! -d $L_OFFICIAL_TL_DIR ]
    then
        echo "WARNING : testline configuration directory $L_OFFICIAL_TL_DIR is missing"

        L_OFFICIAL_TL_DIR="/home/ute/testline_init_results/configs/${G_TL_NAME}"

        if [ ! -d $L_OFFICIAL_TL_DIR ]
        then
            echo "WARNING : testline configuration directory $L_OFFICIAL_TL_DIR is missing"

            # Perhaps we are processing CloudBTS
            L_OFFICIAL_TL_DIR="/home/ute/agent_sim/logs/configs/${G_TL_NAME}"
            if [ ! -d $L_OFFICIAL_TL_DIR ]
            then
                echo "WARNING : testline configuration directory $L_OFFICIAL_TL_DIR is missing"
                echo "ERROR : no test line configuration directory found --> exit"
                exit 1
            fi
        fi
    fi

    L_DST_DIR="${G_ROBOT_DIR}/config/${G_TL_SITE}"

    mkdir -p $L_DST_DIR

    cp -r $L_OFFICIAL_TL_DIR $L_DST_DIR

    # "-cpInitOnly" option is provided --> no more thing to do
    [ $G_CP_INIT_ONLY -eq 1 ] && return

    # patch "__init__.py" file (ex: inserting "_lteemu" before the line "tl ....")

    local L_INIT_FILE="${G_ROBOT_DIR}/config/${G_TL_SITE}/${G_TL_NAME}/__init__.py"

    echo "Patching $L_INIT_FILE"

    # import some libraries, add "_lteemu", update "tl.core" variable
    # put "__all__" in comment to allow other variables, declared in __init__.py, being seen in ROBOT scripts

    local L_LTE_EMU="\
_lteemu = LTEEmuCore(\n  \
         default_ssh_connection_details=SshServiceDetails(\n  \
             addr='${G_TL_ADDRESS}', username='${G_TL_USER}', password='${G_TL_PASSWORD}'),\n  \
         dir_path='/opt/iphy/latest/',\n  \
         cfg_filename='basic_wts_step2.cfg',\n  \
         mme_ip='',\n  \
         edaemon_port='22222', egate_port='9880')\n"

    cp ${L_INIT_FILE} "${L_INIT_FILE}.bkp"

    awk -v lte_emu="${L_LTE_EMU}" '/^tl/ && c1 == 0       {c1 = 1; print lte_emu}; \
                                   /ues=/ && c2 == 0      {c2 = 1; print "              core=_lteemu,"}; \
                                   /_CFG_DIR/ && c3 == 0  {c3 = 1; print "from taf.config.testline.core import EPCSim, LTEEmuCore"}; \
                                   /^__all__/ && c4 == 0  {c4 = 1; print "# " $0; next}; \
                                   {print}'  ${L_INIT_FILE} > ${L_INIT_FILE}.tmp

    # add port 443, after the password, for using https
    sed "s/password=\"nemuuser\"/password=\"nemuuser\", port=\"443\"/"  ${L_INIT_FILE}.tmp > ${L_INIT_FILE}

    rm ${L_INIT_FILE}.tmp
}



# -------------------------------------------------------------------
# Set up the test command
# -------------------------------------------------------------------

function SetupTestCommand() {
set -xv

    local L_TEST_CASE=$1
    local L_LOG_FILE=$2

    # Get the short build ID (ex: "5G20A_9.1800.276" --> "9.1800.276")
    local L_SHORT_GNB_BUILD_ID=$(echo ${G_GNB_BUILD_ID} | cut -d "_" -f 2)

    # python3 -m robot -V config/Wroclaw/2_16_UTE5GCLASSICAL1552/ -v version:9.1800.293 -v AF_PATH:https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/9.1800.293/AirFrameVirtualized-9.1800.293.qcow2 -d $LOG_DIR -L DEBUG -b debug.log  testsuite/RRM/ECE/UE_Call_Setup/5GC000636-D/5GC000636-D_ClassicalTestCases.robot

    # full path to the load (WITHOUT "/" AT THE END)
    local L_AF_PATH="https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/${L_SHORT_GNB_BUILD_ID}/AirFrameVirtualized-${L_SHORT_GNB_BUILD_ID}.qcow2"

    # set test case option if needed (test cases are comma separated)

    local L_TEST_CASE_OPTION=""

    if [ -n "$L_TEST_CASE" ]
    then
        local L_TC
        local L_TC_LIST

        L_TC_LIST=$(echo $L_TEST_CASE | tr "," " ")

        for L_TC in $L_TC_LIST
        do
            L_TEST_CASE_OPTION="${L_TEST_CASE_OPTION} -t ${L_TC}"
        done

        # replace "[1]" by "?1?" as robot 3.1.2 considere "[1]" as variable index
        L_TEST_CASE_OPTION=$(echo $L_TEST_CASE_OPTION | sed "s/\[1\]/\?1\?/g")
    fi

    # manage other options
    local L_OPTIONS=""

    if [ $G_DRY_RUN -eq 1 ]
    then
        L_OPTIONS="${L_OPTIONS} --dryrun"
    fi

    if [ $G_HIRE_SHERPA -eq 1 ]
    then
        L_OPTIONS="${L_OPTIONS} -v hire_a_sherpa:True"
    fi

    if [ $G_SOS_REPORT -eq 0 ]
    then
        L_OPTIONS="${L_OPTIONS} -v sosReport:False"
    fi

    # setup the test command

    local L_CMD

    if [ $G_USE_PYTHON3 -eq 1 ]
    then

          L_CMD="mkdir -p ${G_LOGS_DIR} && \
                 cd ${G_ROBOT_DIR} && \
                 export PYTHONPATH=$PYTHONPATH:${G_ROBOT_DIR} && \
                 python3 -m robot \
                         -V config/${G_TL_SITE}/${G_TL_NAME}/ \
                         -v ENB_BUILD:${G_GNB_BUILD_ID} \
                         -v TMP_PATH:${G_LOGS_DIR} \
                         -d ${G_LOGS_DIR} \
                         -L DEBUG -b debug.log \
                         $L_TEST_CASE_OPTION $L_OPTIONS \
                         ${G_TEST_SUITE} | tee -a ${L_LOG_FILE}"
    else

          L_CMD="mkdir -p ${G_LOGS_DIR} && \
                 cd ${G_ROBOT_DIR} && \
                 export PYTHONPATH=$PYTHONPATH:${G_ROBOT_DIR} && \
                 robot \
                         -V config/${G_TL_SITE}/${G_TL_NAME}/ \
                         -v ENB_BUILD:${G_GNB_BUILD_ID} \
                         -v TMP_PATH:${G_LOGS_DIR} \
                         -d ${G_LOGS_DIR} \
                         -L DEBUG -b debug.log \
                         $L_TEST_CASE_OPTION $L_OPTIONS \
                         ${G_TEST_SUITE} | tee -a ${L_LOG_FILE}"
    fi

    echo "$L_CMD"
}



# -------------------------------------------------------------------
# Execute tests
# -------------------------------------------------------------------

function ExecuteTest ()
{
set -xv

    local L_LOG_FILE=$1

    if [ -z "${G_TEST_CASE}" ]
    then
        # no test case provided --> run the full test suite
        local L_TEST_CMD=$(SetupTestCommand "" "${L_LOG_FILE}")
        eval $L_TEST_CMD
        return
    fi

    if [ "$G_SPLIT_MODE_ON" == "true" ]
    then
        # run testcases one by one
        local L_TC
        local L_TC_LIST

        L_TC_LIST=$(echo $G_TEST_CASE | tr "," " ")

        for L_TC in $L_TC_LIST
        do
            local L_TEST_CMD=$(SetupTestCommand "${L_TC}" "${L_LOG_FILE}")
            eval $L_TEST_CMD
        done
    else
        # run all test cases in sequence
        local L_TEST_CMD=$(SetupTestCommand "${G_TEST_CASE}" "${L_LOG_FILE}")
        eval $L_TEST_CMD
    fi
}



# -------------------------------------------------------------------
# Run tests, send tests results to COOP and tranfer tests output to
# the workspace
# -------------------------------------------------------------------

function RunTest()
{
set -xv

    Step "RUN Tests"

    # setup the log files
    local L_LOG_FILE="${G_LOGS_DIR}/crt_ute_run_test.log"

    # activate virtual env on UTE test line to have access to TAF libratries
    # (automatically done in "Single Run")
    source /home/ute/test_repo/bin/activate

    local L_CMD=""

    if [ $G_USE_PYTHON3 -eq 1 ]
    then
        # python3 --> install needed packages
        L_CMD="\
               cd ${G_ROBOT_DIR} && \
               pip3 install -r requirements.cfg"

        if [ "$G_NW_ARCH" == "SA" ]
        then
            L_CMD="${L_CMD} && pip3 install taf.lteemu==3.21.0"
        else
            L_CMD="${L_CMD} && pip3 install taf.lteemu==2.17.1"
        fi
    else
        # python2 --> install only lteemu 3.21.0 for SA
        if [ "$G_NW_ARCH" == "SA" ]
        then
            L_CMD="pip install taf.lteemu==3.21.0"
        fi
    fi

    [ -n "${L_CMD}" ] && eval $L_CMD

    # run tests
    ExecuteTest $L_LOG_FILE

    # create the tar file containing all output data
    (
        cd $G_LOGS_DIR
        tar cvf ${G_HOME_DIR}/crt_output.tar *
    )

    local L_TMP_FILE="/tmp/crt_ute_run_test.$$.tmp"

    # Check if tests were OK

    grep "FATAL_ERROR:" $L_LOG_FILE > $L_TMP_FILE

    local L_NB_ERROR=$(grep -c "FATAL_ERROR:" ${L_TMP_FILE})

    if [ $L_NB_ERROR -ne 0 ]; then
        echo "****** FOUND $L_NB_ERROR errors while running tests *******"
        grep "FATAL_ERROR:" $L_TMP_FILE
        return 1
    fi

    return 0
}


function CheckParametersAndSetDefaultValues
{
set -xv

    # check mandatory parameters

    if [ -z "$G_TL_SITE" ] || [ -z "$G_TL_NAME" ] | [ -z "$G_TL_ADDRESS" ] || [ -z "$G_TL_USER" ] || \
       [ -z "$G_TL_PASSWORD" ] || [ -z "$G_TEST_SUITE" ] || [ -z "$G_GNB_BUILD_ID" ]
    then
        echo "ERROR : missing of mandatory parameters"
        exit 1
    fi

    # set default values

    [ -z "$G_NW_ARCH" ] && G_NW_ARCH="NSA"

    echo "Network architecture = $G_NW_ARCH"

    if [ "$G_NW_ARCH" != "NSA" ] && [ "$G_NW_ARCH" != "SA" ]
    then
        echo "ERROR: unknown network architecture $G_NW_ARCH (must be NSA or SA)"
        exit 1
    fi
}


# ---------------------------------------------------------------------------------------
# Parse script parameters
# ---------------------------------------------------------------------------------------

function ReadParameters()
{
set -xv

    while [ $# -ge 1 ]
    do
        case "$1" in
            -tlSite)
                # the  TL location
                G_TL_SITE=$2
                shift
                ;;

            -tlName)
                # the  TL name
                G_TL_NAME=$2
                shift
                ;;

            -tlAddress)
                # the  TL IP address
                G_TL_ADDRESS=$2
                shift
                ;;

            -tlUser)
                # the TL user/login
                G_TL_USER=$2
                shift
                ;;

            -tlPassword)
                # the TL password
                G_TL_PASSWORD=$2
                shift
                ;;

            -testBranch)
                # the branch to be used for current test (default = master)
                G_TEST_BRANCH=$2
                shift
                ;;

            -testSuite)
                # test suite to be used
                G_TEST_SUITE=$2
                shift
                ;;

            -testCase)
                # test suite to be used
                G_TEST_CASE=$2
                shift
                ;;

            -nwArch)
                # network architecture (input is converted to uppercase letters : NSA or SA)
                G_NW_ARCH=${2^^}
                shift
                ;;

            -wtsCfgDir)
                # directory where WTS config file are stored
                G_WTS_CFG_DIR=$2
                shift
                ;;

           -gnbBuildId)
                # GNB load ID
                G_GNB_BUILD_ID=$2
                shift
                ;;

           -python3)
                # use of PYTHON3 instead of the UTE default python (2.7 currently)
                G_USE_PYTHON3=1
                ;;

           -keepInit)
                # keep the existing TL config directory
                # (i.e do not copy the TL config directory and do not patch the TL "__init__.py" file)
                G_KEEP_INIT=1
                ;;

           -cpInitOnly)
                # copy the TL config directory but do not patch __init__.py file
                G_CP_INIT_ONLY=1
                ;;

           -dryrun)
                # run test in dryrun mode
                G_DRY_RUN=1
                ;;

           -hireSherpa)
                # run test in dryrun mode
                G_HIRE_SHERPA=1
                ;;

           -noSosReport)
                # skip the SoSReport creation
                G_SOS_REPORT=0
                ;;

            *)
                echo "Unknown parameters !"
                exit $G_NOK
                ;;
        esac
        shift
    done
}



function DownloadAndInstallSherpa()
{
    set -xv

    # latest version can be found using the below commands
    # wget -N  https://artifactory-espoo1.int.net.nokia.com/artifactory/sherpa-local/pool/ > /dev/null 2>&1 ; \
    # cat index.html | grep sherpa5g_ | cut -d">" -f2 | cut -d/ -f1

    local L_SHERPA_REPO="https://artifactory-espoo1.int.net.nokia.com/artifactory/sherpa-local/pool"

    local L_SHERPA_URL="${L_SHERPA_REPO}/sherpa5g_18_debian10/Sherpa_5G_1.0.55.0.debian10.deb"

    # check if the file is present

    if [[ "$(wget -S --spider $L_SHERPA_URL  2>&1 | grep '200 OK')" == "" ]]
    then
        echo "ERROR : file $L_SHERPA_URL does not exist"
        exit 1
    fi

    # check if the package was installed

    local L_SHERPA_FILE=$(basename $L_SHERPA_URL)

    local L_DEST_FILE="/opt/Nokia/${L_SHERPA_FILE}"

    if [ -n "$(ls $L_DEST_FILE)" ] || [ -n "$(dpkg-query -l | grep sherpa)" ]
    then
        echo "Sherpa was already installed --> nothing to do"
        return 0
    fi

    # download the file

    wget  $L_SHERPA_URL -O $L_DEST_FILE

    if [ $? -ne 0 ]
    then
        echo "ERROR : failed to download $L_SHERPA_URL"
        exit 1
    fi

    # install
    sudo dpkg -i $L_DEST_FILE

    if [ $? -ne 0 ]
    then
        echo "ERROR : failed to install $L_DEST_FILE"
        exit 1
    fi
}



# -------------------------------------------------------------------
# MAIN function
# -------------------------------------------------------------------

function main()
{
set -xv

    if [ $G_INSTALL_SHERPA -eq 1 ]
    then
        DownloadAndInstallSherpa
    fi

    # ADT - no need to add addresses anymore
    if [ $ADD_ETH3_ADDR ]
    then
        # NSA testline --> add needed IP addresses to the VM
        [ "$G_NW_ARCH" == "NSA" ] && AddEth3Addr
    fi

    # Patching sources and config files
    PatchingFiles
    [ $? -ne 0 ] && exit 1

    # run tests
    RunTest
    [ $? -ne 0 ] && exit 1

    exit 0
}



ReadParameters $*

CheckParametersAndSetDefaultValues

main

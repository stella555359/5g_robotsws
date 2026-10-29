#!/bin/bash

# set -xv

G_NO_PYTHON_UPDATE=${NO_PYTHON_UPDATE}

# Customizable parameters
#------------------------

# Release will be dynamically get from Launch execution in "TLConfig.release.name" line
# G_RELEASE="NOT DEFINED"

# G_VIRTUAL_ENV_DIR="${HOME}/virtualenv"	# TBD

# file used to activate virtual env
# G_VIRTUAL_ENV_FILE="$G_VIRTUAL_ENV_DIR/bin/activate"

G_HOME_DIR="/home/ute"

# CRT base directory
G_ROOT_DIR="${G_HOME_DIR}/CrtRoot"

# "Auto5G" cannot be used as it's not a git dir (missing of git config data)
# G_ROBOT_DIR="${G_ROOT_DIR}/robotws5g"
G_ROBOT_DIR="${G_ROOT_DIR}/robotws"

# directory used for storing test output (*.log, *.html, ...)
G_LOGS_DIR="${G_ROOT_DIR}/logs/CrtTest_$(date '+%Y_%m_%d-%H_%M')"

G_CI_DIR="$G_ROBOT_DIR/testsuite/CRT/ParisSaclay/tools/CI"

# tool to be used for generating CI report
G_REPORT_TOOL="${G_CI_DIR}/crt_htmlReport.py"

# Path to launcher script to execute several robot files
G_LAUNCHER_PATH="$G_ROBOT_DIR/testsuite/CRT/ParisSaclay/tools/Launcher"

# file to store all test output data
G_TAR_FILE="CrtTestOutput.tar"

# For display
G_STEP=0

G_DRYRUN=0

# set to 1 to install SHERPA packages on the TL VM 
G_INSTALL_SHERPA=0

# set to 1 in case of local TL
G_LOCAL_TESTLINE=0

# set to 1 to install some IP addresses
G_ADD_ETH3_ADDR=0

# set to 1 to force running  all test with the provided topology
G_FORCED_TAG=0

# Test result is by default set to FAIL:
G_TEST_RESULT="FAIL"

function Step()
{
    local __title=$1

    let G_STEP=G_STEP+1

    echo "=========================================================="
    echo "STEP $G_STEP : $__title"
    echo "=========================================================="
}


# -------------------------------------------------------------------
# Patching sources and config files --> TBD
# -------------------------------------------------------------------

function PatchingFiles ()
{
# set -xv

    local L_SRC_FILE
    local L_DST_DIR

PATCHING_FILES=0

if [ $PATCHING_FILES -eq 1 ]
then

    # copy sources files which must be patched

    echo "Patching sources"

    local L_SRC_FILE="${G_HOME_DIR}/CfgConfig.py"
    local L_DST_DIR="${G_ROBOT_DIR}/testsuite/Paris/resources/SWENG/python"
    cp ${L_SRC_FILE} ${L_DST_DIR}

    local L_SRC_FILE="${G_HOME_DIR}/CB009007_TDD_FR1_SA.robot"
    local L_DST_DIR="${G_ROBOT_DIR}/testsuite/Paris/RRM/ET/CB009007"
    cp ${L_SRC_FILE} ${L_DST_DIR}

fi

# do not copy config files, do not add IP addresses and do not patch __init__.py file
# as these data are dynamically setup by "Ute Env Setup" KW when running on UTE TL

PATCHING_CFG_FILES=0

if [ $PATCHING_CFG_FILES -eq 1 ]
then

    # copy airphone config file : the .xml file name is taken from the .cfg file

    echo "Patching configuration files"

    L_SRC_FILE="${G_HOME_DIR}/basic_wts_step2.cfg"
    L_DST_DIR="/opt/iphy/latest"
    cp ${L_SRC_FILE} ${L_DST_DIR}

    # example of line containing XML file name
    # "set_uec file=AirPhoneConfig.xml id=1 ip=$DAEMON_IP:$DAEMON_PORT peer=$DAEMON_IP:2152 gtpu=off retries=3"
    # -->  get the substring starting right after "file=" then get the 1st word

    local L_XML_CFG_LINE=$(egrep "^set_uec" $L_SRC_FILE)
    local L_XML_FILE=$(echo ${L_XML_CFG_LINE#*file=} | cut -d" " -f1)

    L_SRC_FILE="${G_HOME_DIR}/${L_XML_FILE}"
    L_DST_DIR="/opt/iphy/latest"
    cp ${L_SRC_FILE} ${L_DST_DIR}

fi   # PATCHING_CFG_FILES

COPYING_TL_INIT_FILE=1

if [ $COPYING_TL_INIT_FILE -eq 1 ]
then
    # copy the testline configuration ( __init__.py) from the official directory to the working dir
    # (in case a test branch is used, the testline configuration may be missing in the branch)

    echo "Copying $G_TL_NAME configuration directory"

    # check "testline_configuration" first
    # (otherwise issue with NPS TL100  data under Auto5g is not up to date)

    local L_OFFICIAL_TL_DIR="/home/ute/testline_configuration/${G_TL_NAME}"

    if [ ! -d $L_OFFICIAL_TL_DIR ]
    then
        echo "WARNING : testline configuration directory $L_OFFICIAL_TL_DIR is missing"

        # next TL configuration directory

        L_OFFICIAL_TL_DIR="/home/ute/testline_init_results/configs/${G_TL_NAME}"

        if [ ! -d $L_OFFICIAL_TL_DIR ]
        then
            echo "WARNING : testline configuration directory $L_OFFICIAL_TL_DIR is missing"

            L_OFFICIAL_TL_DIR="/home/ute/agent_sim/logs/configs/${G_TL_NAME}"

            if [ ! -d $L_OFFICIAL_TL_DIR ]
            then
                echo "ERROR : testline configuration directory $L_OFFICIAL_TL_DIR is missing"
                exit 1
            fi
        fi
    fi

    echo "INFO : testline configuration directory used is: $L_OFFICIAL_TL_DIR"
    
    L_DST_DIR="${G_ROBOT_DIR}/config/${G_TL_SITE}"

    mkdir -p $L_DST_DIR

    cp -r $L_OFFICIAL_TL_DIR $L_DST_DIR

    # put in comment the line "__all__=['lt']" at the end of file which prevents other variables, delared in this file,
    # to be exported to ROBOT (issue seen by Andayani, Dwiajeng with L1ByPass declared in __init__.py file, solution
    # proposed by Bernard but will not be applicable when running using CIT/CRT mecanism)
    local L_INIT_FILE="${L_DST_DIR}/${G_TL_NAME}/__init__.py"
    local L_BKP_FILE="${L_DST_DIR}/${G_TL_NAME}/__init__.py.bkp"
    local L_TMP_FILE="${L_INIT_FILE}.$$"

    cp $L_INIT_FILE $L_BKP_FILE
    cat $L_INIT_FILE | sed "s/^__all__.*/#__all__.*/" > $L_TMP_FILE
    mv $L_TMP_FILE $L_INIT_FILE
fi

PATCHING_TL_INIT_FILE=0

if [ $PATCHING_TL_INIT_FILE -eq 1 ]
then

    local L_INIT_FILE="${L_DST_DIR}/${G_TL_NAME}/__init__.py"

    echo "Patching $L_INIT_FILE"

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
                                    {print}'  ${L_INIT_FILE} > ${L_INIT_FILE}.tmp

    mv ${L_INIT_FILE}.tmp ${L_INIT_FILE}

fi   # PATCHING_TL_INIT_FILE
}



# -------------------------------------------------------------------
#    $1 : boolean indicating if sources must be donwloaded from GIT
#    $2 : destination directory
# -------------------------------------------------------------------

function DownloadSources ()
{
# set -xv

    local L_DEST_DIR=$1
    local L_TEST_BRANCH=$2
    local L_CMD=""

    Step "DOWNLOAD Sources"

DOWNLOADING_SRC=1

if [ $DOWNLOADING_SRC -eq 1 ]
then

    # repository where tests scripts are stored
    # local L_GERRIT_REPO="git@wrgitlab.int.net.nokia.com:5G/robotws5g.git"
    local L_GERRIT_REPO="git@wrgitlab.ext.net.nokia.com:RAN/robotws.git"

    # check the destination dir on the remote VM
    local L_CMD="ls -l ${L_DEST_DIR}/.git"
    eval $L_CMD

    if [ $? != 0 ]
    then
        # file does not exist --> the destination dir is not a GIT dir --> clone sources

        # ADT - juin 7th 2022 - remove recursive option to avoid error cloning "config" directory
        #       git clone --recursive ${L_GERRIT_REPO} ." 

        echo "Cloning sources from $L_GERRIT_REPO into ${L_DEST_DIR}"
        L_CMD="mkdir -p ${L_DEST_DIR} && \
               cd ${L_DEST_DIR} && \
               git clone ${L_GERRIT_REPO} ." 
    else
        # the destination dir is a GIT dir --> update it's content
        echo "Updating sources in ${L_DEST_DIR}"
        L_CMD="cd ${L_DEST_DIR} && \
               git status && \
               git checkout . && \
               git checkout master  && \
               git pull"

    fi

    USE_SPECIFIC_SHA1=0

    if [ $USE_SPECIFIC_SHA1 -eq 1 ]
    then
        # checkout the last working version
        local L_HASH_ID="5cf0e16f165e17c97ffcccbefbe5266cdbeefb34"
    
        # git checkout $L_HASH_ID
        # git reset --hard $L_HASH_ID

        L_CMD="${L_CMD} && \
               git checkout \"${L_HASH_ID}\""
    fi

    # get sources from test branch (NPS_CRT_DEV) or from master
    if [ -z "$L_TEST_BRANCH" ]
    then
        L_TEST_BRANCH="master"
    fi

    echo "Using sources from branch ${L_TEST_BRANCH}"
    L_CMD="${L_CMD} && \
           git checkout \"${L_TEST_BRANCH}\" && \
           git pull"

    # execute commands
    eval $L_CMD
    if [ $? -ne 0 ]
    then
        echo "ERROR - failure cloning/updating sources"
        exit 1
    else
        echo "Sources downloaded OK"
    fi

fi # DOWNLOADING_SRC

}



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
# If the test line topology does not exist in the test script then
# patch it by inserting the topology in the section  "Force tags"
# -------------------------------------------------------------------

function PatchingTestScript ()
{
    local L_TEST_SUITE=$1

    if [ ${G_FORCED_TAG} -ne 1 ]
    then
        # do not patch any thing
        return
    fi

    # recover the original file before patching it

    local L_TEST_SUITE_PATH="${G_ROBOT_DIR}/${L_TEST_SUITE}"

    git checkout ${L_TEST_SUITE_PATH}

    # Replace existing tags with an arbitrary string
    # so that these tags will be ignored and all tests will be associated with the topo being
    # used for running test ("CLOUD_5G_I_" is the prefix for all existing tags)
    sed -i "s/CLOUD_5G_I_/XXXXX_/g" ${L_TEST_SUITE_PATH}
    
    # check if the topology is already present in the test suite

    local L_EXISTING_TAG=$(grep -w ${G_UTE_TOPOLOGY} ${L_TEST_SUITE_PATH})

    if [ -z "${L_EXISTING_TAG}" ]
    then
        # tag does not exist in the test suite --> add it after "Force tags" line

        local L_LINE_TO_ADD="...            ${G_UTE_TOPOLOGY}"

        awk -v line_to_add="${L_LINE_TO_ADD}" '{
            if(match ($0, "^Force Tags"))
            {
            print ; print line_to_add
            }
            else
            {
            print 
            }
        }' ${L_TEST_SUITE_PATH}  > ${L_TEST_SUITE_PATH}.tmp

        cp -p ${L_TEST_SUITE_PATH}.tmp ${L_TEST_SUITE_PATH}
    fi
}



# -------------------------------------------------------------------
# Set up the test command
# -------------------------------------------------------------------

function SetupTestCommand() {
# set -xv

    local L_TEST_CASE=$1
    local L_LOG_FILE=$2
    local L_TEST_SUITE=$3
    local L_LOGS_DIR=$4

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

        # L_TEST_CASE_OPTION=$(echo $L_TEST_CASE_OPTION | sed "s/\[1\]/\?1\?/g")

        L_TEST_CASE_OPTION=$(echo $L_TEST_CASE_OPTION | sed "s/\[/\?/g")
        L_TEST_CASE_OPTION=$(echo $L_TEST_CASE_OPTION | sed "s/\]/\?/g")
    fi

    # setup the test command
    local L_ROBOT_CMD="python3 -m robot"

    local L_DRYRUN_OPTION=""

    if [ $G_DRYRUN -eq 1 ]
    then
        L_DRYRUN_OPTION="--dryrun"
    fi

    
    local L_NETWORK_TYPE_OPTION=""
    [ -n "${G_NETWORK_TYPE}" ] && L_NETWORK_TYPE_OPTION="-v deploy:${G_NETWORK_TYPE}"

    # setup tags option (to include tags used for selecting test cases and for displaying statistics in the log.html header)
    local L_SETTAGS_OPTION=""
    if [ -n "$G_UTE_TOPOLOGY" ]
    then
        # ADT - NEW - include the selection of testcase using the topology only if no FORCED_TAG
        if [ ${G_FORCED_TAG} -eq 0 ]
        then
           # set the topology tag used for selecting test cases
           L_SETTAGS_OPTION="--include $G_UTE_TOPOLOGY"
        fi

        # set tags to be included in statistics section
        L_SETTAGS_OPTION+=" --tagstatinclude $G_UTE_TOPOLOGY --tagstatinclude 5G_RAN --tagstatinclude CA_5G_SW_FR-Villarceaux"
        L_SETTAGS_OPTION+=" --tagstatinclude CONFIGURED --tagstatinclude RRM --tagstatinclude SBTS00 --tagstatinclude SBTS21B"
    fi

    # ADT - NEW - do not need to patch file anymore in case of "FORCED_TAG"
    # PatchingTestScript ${L_TEST_SUITE}

    # setup the command to run the test
    local L_CMD="mkdir -p ${L_LOGS_DIR} && \
                 cd ${G_ROBOT_DIR} && \
                 ${L_ROBOT_CMD} \
                         -V config/${G_TL_SITE}/${G_TL_NAME}/ \
                         -v ENB_BUILD:${G_GNB_BUILD_ID} \
                         -v TMP_PATH:${L_LOGS_DIR} \
                         -v hire_a_sherpa:${G_HIRE_SHERPA}
                         -v sosReport:${G_SOSREPORT_IFFAILED} 
                         -v SharkTool:${G_SHARK_TOOL}
                         ${G_ROBOT_EXT_VAR} \
                         -d ${L_LOGS_DIR} \
                         -L DEBUG -b debug.log \
                         $L_NETWORK_TYPE_OPTION \
                         $L_TEST_CASE_OPTION \
                         $L_DRYRUN_OPTION \
                         $L_SETTAGS_OPTION \
                         ${L_TEST_SUITE} 2>&1 | grep -v 'contains no keywords' | tee -a ${L_LOG_FILE}"

    echo "$L_CMD"
}



# -------------------------------------------------------------------
# Execute tests
# -------------------------------------------------------------------

function ExecuteTest ()
{ 
# set -xv

    local L_LOG_FILE=$1
    local L_TEST_SUITE=$2
    local L_LOGS_DIR=$3
    local L_TEST_CASE=$4

    local L_TEST_CMD

    if [ -z "${L_TEST_CASE}" ]
    then
        # no test case provided --> run the full test suite
        L_TEST_CMD=$(SetupTestCommand "" "${L_LOG_FILE}" "${L_TEST_SUITE}" "${L_LOGS_DIR}")
        eval $L_TEST_CMD
        return
    fi

    # run all test cases in sequence
    L_TEST_CMD=$(SetupTestCommand "${L_TEST_CASE}" "${L_LOG_FILE}" "${L_TEST_SUITE}" "${L_LOGS_DIR}")
    eval $L_TEST_CMD
}


# -------------------------------------------------------------------
# Set up the test environment
# -------------------------------------------------------------------

function SetupTestEnv()
{
# set -xv

    Step "Setup the test environment"

    # activate virtual env on UTE test line to have access to TAF libratries
    # (automatically done in "Single Run")
    source /home/ute/test_repo/bin/activate

    # remove the existing tar file to avoid using old data for archiving in Jenkins job
    rm /home/ute/crt_output.tar > /dev/null 2>&1
}


function CheckTestResult ()
{
    local L_LOG_FILE=$1

    local L_TMP_FILE="/tmp/TmpData.$$.dat"

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


# -------------------------------------------------------------------
# Description
#     Check if the testcase is PASS or not
#         $1: The log filename
#         $2: testcase name
# Return
#     PASS or FAIL
# -------------------------------------------------------------------

function CheckTestcaseResult ()
{
    local L_LOG_FILE=$1
    local L_TESTCASE_NAME=$2
    local L_TMP_FILE="/tmp/TmpData.$$.dat"

    local L_CMD=""

    echo "Passed or Failed - Check for : ${L_TESTCASE_NAME}"

    # A testcase is passed if one of the following patterns is found in log file:
    # "1 test, 1 passed, 0 failed" or "X tests, X passed, 0 failed" or "X test total, X passed, 0 failed"
    # The common part of them is "passed, 0 failed"
    grep -e "test[s ,][t ,]" $L_LOG_FILE | grep -e "passed, 0 failed" > $L_TMP_FILE
    local L_NB_OF_PATTERN_0_failed=$(grep -c "passed, 0 failed" ${L_TMP_FILE})

    if [ $L_NB_OF_PATTERN_0_failed -ne 0 ]; then
        G_TEST_RESULT="PASS"
        echo "${L_TESTCASE_NAME} - ALL TESTCASES ARE PASSED"
        return 0
    else
        G_TEST_RESULT="FAIL"
        echo "${L_TESTCASE_NAME} - AT LEAST ONE TESTCASE IS FAILED OR NOT EXECUTED OR ..."
        return 1
    fi

}


# ADT - extract the "SetupTestEnv" part

function RunTest()
{
# set -xv

    local L_TEST_SUITE

    local L_TEST_NAME

    local L_LOGS_DIR

    local L_LOG_FILE

    local L_TEST_CASE

    local L_GLOBAL_TEST_RESULT=0

    local L_NB_TEST_SUITE=$(echo ${G_TEST_SUITE} | sed "s/,/ /" | wc -w)

    # loop through the comma separated list of test suites
    for L_TEST_SUITE in $(echo ${G_TEST_SUITE} | sed "s/,/ /g")
    do
        # get the test suite name  (without .robot extension)
        L_TEST_NAME=$(basename $L_TEST_SUITE | sed "s/\.robot//")

        # separated log directory for each test suite
        L_LOGS_DIR="${G_LOGS_DIR}/${L_TEST_NAME}"

        L_LOG_FILE="${L_LOGS_DIR}/crt_ute_run_test.log"

        # if run multi test suite --> ignore CRT_TEST_CASE
        [ ${L_NB_TEST_SUITE=} -eq 1 ] && L_TEST_CASE=${G_TEST_CASE} || L_TEST_CASE=""

        # run a test suite
        ExecuteTest $L_LOG_FILE $L_TEST_SUITE $L_LOGS_DIR $L_TEST_CASE
  
        # save the original WTS basic.cfg and basic.modified.cfg
        cp /opt/iphy/latest/basic_wts_step2.cfg ${L_LOGS_DIR}
        cp /tmp/ute/basic_wts_step2.cfg ${L_LOGS_DIR}/basic_wts_step2.modified.cfg

        # save egate_console.log
        cp /opt/iphy/latest/egate_console* ${L_LOGS_DIR}

        # save the alarm file (created before starting the test)
        G_STATUS_FILE=$(find ${L_LOGS_DIR}/Logs -name Status_Before_Testsuite.txt)
        [ -n "$G_STATUS_FILE" ] && cp $G_STATUS_FILE ${L_LOGS_DIR} 

        CheckTestResult $L_LOG_FILE

        # Search if testcase is PASS or FAIL:
        CheckTestcaseResult $L_LOG_FILE $L_TEST_SUITE

        # the global test result will be equal to 1 if at least 1 of tests was KO
        ((L_GLOBAL_TEST_RESULT^=$?))
        echo "L_GLOBAL_TEST_RESULT is $L_GLOBAL_TEST_RESULT"
    done

    # create the tar file containing all output data 
    (
        cd ${G_LOGS_DIR}
        tar cvfz ${G_HOME_DIR}/crt_output.tar *
    )

    return $L_GLOBAL_TEST_RESULT
}



function DownloadAndInstallSherpa()
{
# set -xv

    # latest version can be found using the below commands
    # wget -N  https://artifactory-espoo1.int.net.nokia.com/artifactory/sherpa-local/pool/ > /dev/null 2>&1 ; \
    # cat index.html | grep sherpa5g_ | cut -d">" -f2 | cut -d/ -f1

    local L_SHERPA_REPO="https://artifactory-espoo1.int.net.nokia.com/artifactory/sherpa-local/pool"
    
    # local L_SHERPA_URL="${L_SHERPA_REPO}/sherpa5g_18_debian10/Sherpa_5G_1.0.55.0.debian10.deb"
    local L_SHERPA_URL="${L_SHERPA_REPO}/sherpa5g_18_debian10/Sherpa_5G_1.0.61.0.debian10.deb"

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


function DownloadAndInstallLuashark()
{
# set -xv

    local L_LUASHARK_REPO="https://xxx"

    echo "FUNCTION TO BE DEFINED"

    # download .zip file
    # sudo mkdir -p /opt/luashark
    # sudo "cd  /opt/luashark
    # sudo unzip file.zip

    return 0
}



# ---------------------------------------------------------------------------------------
# Parse script parameters
# ---------------------------------------------------------------------------------------

function ReadParameters()
{
# set -xv
    G_ROBOT_EXT_VAR=" "
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

            -hireSherpa)
                # enable sherpa if implemented by test
                G_HIRE_SHERPA=$2
                shift
                ;;

            -aeptlupgrade)
                G_AEPTLUPGRADE=$2
                shift
                ;;

            -sosReport)
                # enable sherpa if implemented by test
                G_SOSREPORT_IFFAILED=$2
                shift
                ;;

            -sharkTool)
                # MC_Shark or Lua_Shark selection
                 G_SHARK_TOOL=$2
                shift
                ;;

            -dryrun)
                # un test in "dryrun" mode
                G_DRYRUN=1
                ;;

            -localTl)
                # use of local TL
                G_LOCAL_TESTLINE=1
                ;;

            -forcedTag)
                # force to run all tests with the provided topology
                G_FORCED_TAG=1
                ;;

            -gnbBuildId)
                # GNB load ID
                G_GNB_BUILD_ID=$2
                shift
                ;;

            -networkType)
                # network type : NSA or sa
                G_NETWORK_TYPE=$2
                shift
                ;;

            -tlTopology)
                # the UTE test line topology
                G_UTE_TOPOLOGY=$2
                shift
                ;;

            -v)
                # allow to define variables in test data
                G_ROBOT_EXT_VAR="${G_ROBOT_EXT_VAR} -v $2"
                shift
                ;;

            *)
                echo "Unknown parameters !"
                exit $G_NOK
                ;;
        esac
        shift
    done
}



# -------------------------------------------------------------------
# MAIN function
# -------------------------------------------------------------------

function main()
{
# set -xv

    if [ $G_INSTALL_SHERPA -eq 1 ] 
    then
        DownloadAndInstallSherpa
    fi  

    if [ $G_LOCAL_TESTLINE -eq 1 ] 
    then
        DownloadAndInstallLuashark
    fi  

    if [ $G_ADD_ETH3_ADDR -eq 1 ] && [ "$G_NETWORK_TYPE" != "SA" ]
    then
        # add needed IP addresses for NSA (no need for SA)
        AddEth3Addr
    fi

    # download tests sources into G_ROOT_DIR
    DownloadSources  "$G_ROBOT_DIR"  "$G_TEST_BRANCH"
    [ $? -ne 0 ] && exit 1

    # set up the test environment
    SetupTestEnv

    # Patching sources and config files
    PatchingFiles

    # run tests
    RunTest
    [ $? -ne 0 ] && exit 1

    exit 0
}



ReadParameters $*

main

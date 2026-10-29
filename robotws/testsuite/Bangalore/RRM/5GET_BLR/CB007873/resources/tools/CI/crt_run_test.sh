#!/bin/bash

# List of parameters defined in jenkins job
# CRT_GNB_LOAD_ID       : Id of the load.                   Example : 0.836.506
# CRT_TEST_BRANCH       : Branch of dev                     Example : NPS_CRT_DEV
# CRT_TEST_LINE_ID      : Name of TL config dir             Example : 7_20_CLASS5GPSECE31
# CRT_LUASHARK_VERSION  : Version of luashark
# CRT_TEST_LINE_DESC    : Description of TL
# CRT_GNB_REPOSITORY    : Location of WFT load              Example : https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
# CRT_AIRPHONE_VERSION  :
# CRT_MAILING_LIST
# CRT_TEST_SCRIPT_ROBOT :
# CRT_DRY_RUN           :
# CRT_NB_EXEC           :

# Below variable must be defined to allow sending mail using "sendmail" command
# If not defined then the Jenkins "Editable Email" plugin is used instead
G_USE_SEND_MAIL=yes

#=========================================================================
# - The file ".../config/ParisSaclay/<test line ID>/__init__.py" must be
# updated to use the account $GLB_VM_LOGIN instead of the existing one
# (in "_host" and "remote_server_user")
# - The $CRT_ROTTA_LOGIN must be present on the VM from where tests are
# executed (a local account will work)
#=========================================================================
SET_BUILD_ENV="source /5g/usde/profiles/master/gnb/latest"
$SET_BUILD_ENV

# set -xv

# Customizable parameters
#------------------------
# Release will be dynamically get from Launch execution in "TLConfig.release.name" line
G_RELEASE="NOT DEFINED"

G_VM_IP="$GLB_VM_IP"

G_VM_LOGIN="$GLB_VM_LOGIN"

G_ROBOT_DIR="/ebs/ca_psci5g/CRT_project/robotws5g"

G_COOP_TOOLS_DIR="/ebs/ca_psci5g/CoopTools"

# G_REPORT_TOOLS_DIR="/ebs/ca_psci5g/ReportTools"
G_CI_ROOT_DIR="$G_ROBOT_DIR/testsuite/CRT/ParisSaclay/tools/CI"
G_REPORT_TOOLS_DIR="$G_CI_ROOT_DIR"

# test output dir
G_TEST_OUTPUT_DIR="/ebs/ca_psci5g/CRT_project/${R_TEST_OUTPUT_DIR}"

# file used to activate virtual env
G_VIRTUAL_ENV_FILE="$G_VIRTUAL_ENV_DIR/bin/activate"

# tool to be used for generating CI report
#G_REPORT_TOOL="${G_REPORT_TOOLS_DIR}/frt_htmlReport.py"
G_REPORT_TOOL="${G_CI_ROOT_DIR}/crt_htmlReport.py"

# tool to be used for pushing tests results and tests logs to COOP
G_COOP_TOOL_1="${G_COOP_TOOLS_DIR}/frt-coop-test-start-trigger.py"
G_COOP_TOOL_2="${G_COOP_TOOLS_DIR}/frt-collector.py"

# test script (related to G_ROBOT_DIR)
G_TEST_SCRIPT=$(echo "${CRT_TEST_SCRIPT_ROBOT}" | sed -e "s/ //g")

# Path to launcher script to execute several robot files
G_LAUNCH_PATH="$G_ROBOT_DIR/testsuite/CRT/ParisSaclay/tools/Launcher"

# URL to download the zip file associated with the load
# (this must be done before starting the robot test script)
G_ZIP_URL="${CRT_GNB_REPOSITORY}/${CRT_GNB_LOAD_ID}/AirScale-${CRT_GNB_LOAD_ID}.zip"

# URL to download the software
# G_LOAD_URL="http://10.135.150.72/artifactory/list/mnp-ececi-artifacts-local/System_Release/${CRT_GNB_LOAD_ID}/AirFrameVirtualized-${CRT_GNB_LOAD_ID}.qcow2"
G_LOAD_URL="${CRT_GNB_REPOSITORY}/${CRT_GNB_LOAD_ID}/AirFrameVirtualized-${CRT_GNB_LOAD_ID}.qcow2"

# file to store all test output data
G_TAR_FILE="FrtTestOutput.tar"

# directory to store data to be archived as artifacts in the job
G_ARCHIVE_DIR="Archive"

# test line configuration dir (related to G_ROBOT_DIR)
G_TEST_LINE_CFG_DIR="config/ParisSaclay/${CRT_TEST_LINE_ID}"

# Site ID (used for sending tests results to COOP)
G_SITE_ID="NPS"

# option to activate sources update or not
G_DOWNLOAD_SRC="true"

# Option For dry run
G_DRY_MODE=$CRT_DRY_RUN

# Option to launch update QC command
G_UPDATE_QC=$CRT_UPDATE_QC

# For display
G_STEP=0

function init() {
    G_SHORT_JOB_NAME=$(echo "$JOB_NAME" | sed -e "s/.*\///g")

}

function Step()
{
    local __title=$1
    let G_STEP=G_STEP+1
    echo "=========================================================="
    echo "STEP $G_STEP : $__title"
    echo "=========================================================="
}

# download tests scripts into directory
#    $1 : boolean indicating if sources must be donwloaded from GIT
#    $2 : destination directory

function DownloadSources ()
{
set -xv
    Step    "DOWNLOAD Sources"
    local L_DOWNLOAD_SRC=$1
    local L_DEST_DIR=$2

    # repository where tests scripts are stored
    local L_GERRIT_REPO="git@wrgitlab.int.net.nokia.com:5G/robotws5g.git"

    local L_CMD

    if [ "$L_DOWNLOAD_SRC" == "false" ]
    then
        # do not download anything in in directory $L_DEST_DIR
        echo "Option CRT_DOWNLOAD_SRC was not selected --> use existing sources under $L_DEST_DIR"

    # try to get the commit from the existing sources
        L_CMD="\
               cd ${L_DEST_DIR} && \
               echo \"***** CURRENT COMMIT = \$(git rev-parse HEAD)\"
               git status"

        ssh ${G_VM_LOGIN}@${G_VM_IP} "$L_CMD"

        return 0
    fi

    if [ ! -d ${L_DEST_DIR}/.git ]
    then
        # the destination dir is not a GIT dir --> clone sources
        echo "Cloning sources form $L_GERRIT_REPO into ${L_DEST_DIR}"
        L_CMD="\
               mkdir -p ${L_DEST_DIR} && \
               cd ${L_DEST_DIR} && \
               git clone --recursive ${L_GERRIT_REPO} . && \
               echo \"***** CURRENT COMMIT = \$(git rev-parse HEAD)\""
    else
        # the destination dir is a GIT dir --> update it's content
        echo "Updating sources in ${L_DEST_DIR}"
        L_CMD="\
               cd ${L_DEST_DIR} && \
               echo \"***** CURRENT COMMIT = \$(git rev-parse HEAD)\" && \
               git status && \
               git pull --rebase && \
               echo \"***** NEW COMMIT = \$(git rev-parse HEAD)\""
    fi

    #Branch special PROSPER
    if [ ! -z "$CRT_TEST_BRANCH" ]
    then
        L_CMD="${L_CMD} && \
               git checkout \"${CRT_TEST_BRANCH}\" && \
               cd config && \
               git checkout \"NPS_FRT\" && \
               git pull --rebase && \
               cd .. "
    fi

    # execute commands on the remote VM
    ssh ${G_VM_LOGIN}@${G_VM_IP} "$L_CMD"
    if [ $? -ne 0 ]
    then
        echo "ERROR - failure cloning/updating sources"
        exit 1
    else
        echo "Sources downloaded OK"
    fi

}

# Compute command to launch all robots
function computeLaunchCmd() {
    # Compute run mode (dryrun or not)
    L_LAUNCH_MODE_STR=""
    if ! $G_DRY_MODE;then L_LAUNCH_MODE_STR="-r"; fi
    # Compute launch update QC command or not
    L_LAUNCH_UPDATE_QC_STR=""
    if $G_UPDATE_QC;then L_LAUNCH_UPDATE_QC_STR="--qc --br"; fi
    # Add luashark version if different from gnb one
    L_LUASHARK_OPTION=""
    if [ ! -z "$CRT_LUASHARK_VERSION" ]; then L_LUASHARK_OPTION="--lua $CRT_LUASHARK_VERSION";  fi
    # Build start of launch command with mandatory arguments
    G_LAUNCH_CMD="sh Launch.sh -v $CRT_GNB_LOAD_ID -t $CRT_TEST_LINE_ID -s $G_TEST_SCRIPT $L_LUASHARK_OPTION"
    # Computing a dedicated launch log file
    TimeStamp=$(date +"%Y%m%d_%H%M%S")
    G_LAUNCH_LOG="Launch.${TimeStamp}.log"
    # Adding options and specificities for CI
    G_LAUNCH_CMD="$G_LAUNCH_CMD -n ${CRT_NB_EXEC} --wft ${CRT_GNB_REPOSITORY} --noPause --ci $L_LAUNCH_MODE_STR $L_LAUNCH_UPDATE_QC_STR| tee $G_LAUNCH_LOG"
}

# run tests, send tests results to COOP and tranfer tests output to the workspace
function RunTest()
{
# set -xv
set -x
    Step    "RUN Tests"
    if [ "$SEND_TEST_DATA" == "true" ]
    then
        # Send "test start indication" to COOP
        local L_TEST_CMD="\
            source $G_VIRTUAL_ENV_FILE && \
            $G_COOP_TOOL_1 $CRT_GNB_LOAD_ID $G_SITE_ID $CRT_TEST_LINE_ID"

        ssh ${G_VM_LOGIN}@${G_VM_IP} $L_TEST_CMD
        if [ $? -ne 0 ]
        then
            echo "***** ERROR : could not send CRT_STARTED indication to COOP server"
        else
            echo "***** CRT_STARTED indication successfully sent to COOP server"
        fi
    fi

    # directory where to download the ZIP file
    local L_ZIP_DEST_DIR="/ebs/ca_psci5g/yaft/YAFT/${CRT_GNB_LOAD_ID}"

    # run test
    computeLaunchCmd
    L_TEST_CMD="\
             source $G_VIRTUAL_ENV_FILE && \
             rm -rf $G_TEST_OUTPUT_DIR && mkdir -p $G_TEST_OUTPUT_DIR && \
             cd $G_ROBOT_DIR && \
             pip install -r requirements.cfg && \
             cd $G_LAUNCH_PATH;$G_LAUNCH_CMD"

    local L_TEST_RESULT

    echo "***** Starting tests"
    ssh ${G_VM_LOGIN}@${G_VM_IP} "$L_TEST_CMD"
    L_TEST_RESULT=$?
    L_RESULT_PATH=$(ssh ${G_VM_LOGIN}@${G_VM_IP} "grep 'Root path for results' $G_LAUNCH_PATH/$G_LAUNCH_LOG  | cut -d : -f2"| sed -e 's/^[[:space:]]*//')
    G_TEST_OUTPUT_DIR=$L_RESULT_PATH
    # Catch release from results
    G_RELEASE=$(ssh ${G_VM_LOGIN}@${G_VM_IP} "grep 'TLConfig.release.name' $G_LAUNCH_PATH/$G_LAUNCH_LOG  | cut -d = -f2"| sed -e 's/^[[:space:]]*//')


    # Check tests were properly launched
    L_NB_ERROR=$(ssh ${G_VM_LOGIN}@${G_VM_IP} "grep -c FATAL_ERROR: $G_LAUNCH_PATH/$G_LAUNCH_LOG")
    if [ $L_NB_ERROR -ne 0 ]; then
        echo "****** FOUND $L_NB_ERROR errors while running tests *******"
        ssh ${G_VM_LOGIN}@${G_VM_IP} "grep FATAL_ERROR: $G_LAUNCH_PATH/$G_LAUNCH_LOG"
        exit -1
    fi

    if [ "$SEND_TEST_DATA" == "true" ]
    then
        # Send data (ouput.xml, report.html, logs.html), generated by the tests, to COOP server
        # (THIS ACTION CAN BE DONE ON JENKINS SLAVE PROVIDING THAT PYTHON & NEEDED PACKAGES ARE AVAILABLE)
        local L_TEST_CMD="\
                      source $G_VIRTUAL_ENV_FILE && \
                      cd $G_TEST_OUTPUT_DIR && \
                      $G_COOP_TOOL_2 $CRT_GNB_LOAD_ID $G_SITE_ID $CRT_TEST_LINE_ID"
        ssh ${G_VM_LOGIN}@${G_VM_IP} $L_TEST_CMD
        if [ $? -ne 0 ]
        then
            echo "***** ERROR : could not upload test data to COOP server"
        else
            echo "***** Test results successfully uploaded to COOP server"
        fi
    fi

    # create a tar file containing all test output data
    ssh ${G_VM_LOGIN}@${G_VM_IP} "cd $G_TEST_OUTPUT_DIR && tar cvf $G_TAR_FILE *"

    path=$(pwd)
    host=$(hostname)
    echo -e "PATH=$path HOST=$hostname R_TEST_OUTPUT_DIR=$R_TEST_OUTPUT_DIR"

    # transfer the tar file to the working dir and extract the content
    # (some files will be archived in the "post build" part)
    scp ${G_VM_LOGIN}@${G_VM_IP}:${G_TEST_OUTPUT_DIR}/${G_TAR_FILE} . && \
    mkdir -p $R_TEST_OUTPUT_DIR && \
    tar xvf ${G_TAR_FILE} -C $R_TEST_OUTPUT_DIR

    if [ $? -ne 0 ]
    then
        echo "***** WARNING: could not transfer or extract data from the tar file previoulsy created by the tests"
    fi
}

# update the mail subject according to the test status generated by G_REPORT_TOOL
function FormatMailSubject()
{
# set -xv
    local L_MAIL_SUBJECT=$1

    # internal_info file contain "ET_STATUS=X" with X=0,2,...
    #  --> X provides the test status (see frt_htmlReport.py for details)
    local L_INTERNAL_INFO_FILE="$R_TEST_OUTPUT_DIR/internal_info"
    local L_TEST_STATUS=$(grep "ET_STATUS=" $L_INTERNAL_INFO_FILE | cut -d= -f2)
    local TEST_STATUS_STR

    if [ $L_TEST_STATUS -eq 0 ]
    then
        TEST_STATUS_STR="NOT RELEASED"
    elif [ $L_TEST_STATUS -eq 2 ]
    then
        TEST_STATUS_STR="RELEASED WITH RESTRICTIONS"
    else
        TEST_STATUS_STR="RELEASED"
    fi

    # replace the substring "%TEST_STATUS%" by the real test status
    L_MAIL_SUBJECT=$(SUB_EXPRESSION="s/%TEST_STATUS%/${TEST_STATUS_STR}/g"; echo $L_MAIL_SUBJECT | sed "$SUB_EXPRESSION")
    echo $L_MAIL_SUBJECT
}



# Generate a new report from output.xml file and send it
function SendReport()
{
# set -xv
    Step    "SEND Report"
    # directory where test data are stored on ROTTA server (path relative to rotta root)
    local L_ROTTA_DIR=$1

    # init the mail file
    local L_MSG_FILE="MailContent.$$.dat"
    local L_SENDER="crt_ci@nokia.com"
    local L_MAIL_SUBJECT="[5GSC_SW_CRT_NPS Release Note] JOB=$G_SHORT_JOB_NAME(#$BUILD_NUMBER) LOAD=${CRT_GNB_LOAD_ID} UE=Airphone : %TEST_STATUS%"

    # exit if mailing list is empty
    if [ -z "$CRT_MAILING_LIST" ]
    then
        echo "WARNING : mailing list is empty --> no mail sent"
        return 0
    fi

    # ROTTA path where test data are stored
    if [ -n "$L_ROTTA_DIR" ]
    then
        local L_ROTTA_ROOT="/mnt/nnf00048/rotta4internal"
        # local L_ROTTA_STORAGE="/mnt/nnf00048/rotta4internal/5G/FRT/4.5833/4.5833.110-ECE+181019.68/NPS"
        local L_ROTTA_STORAGE="${L_ROTTA_ROOT}/${L_ROTTA_DIR}"
        local L_CURRENT_PREFIX="^/mnt/nnf00048"
        local L_NEW_PREFIX="//eseefsn50.emea.nsn-net.net"
        local L_NEW_ROTTA_STORAGE=`echo $L_ROTTA_STORAGE | sed "s#$L_CURRENT_PREFIX#$L_NEW_PREFIX#g"`

        # replace each "/" with "\" (need to use 8 "\" to make the replacement !!!)
        L_NEW_ROTTA_STORAGE=`echo $L_NEW_ROTTA_STORAGE | sed "s#/#\\\\\\\\\\\\\\\\#g"`
        local L_ROTTA_URL="<a href=${L_NEW_ROTTA_STORAGE}>here</a>"

        CRT_ADDITIONAL_INFO="${CRT_ADDITIONAL_INFO}<br><b>[ROTTA storage]&nbsp:&nbsp</b>${L_ROTTA_URL}"
    fi

    # get the test line description
    local L_TEST_LINE_DESC="$CRT_TEST_LINE_ID"
    if [ -n "$CRT_TEST_LINE_DESC" ]; then
        L_TEST_LINE_DESC="$CRT_TEST_LINE_ID-$CRT_TEST_LINE_DESC"
    fi
    # generate ci_report.html from the output.xml file
    # (report.html file, generated by robot tests, cannot be displayed by Outlook)
    (
        cd $R_TEST_OUTPUT_DIR
        if [ -f ./output.xml ]
        then
            python $G_REPORT_TOOL ./output.xml \
                                  "$JOB_NAME" \
                                  "$BUILD_NUMBER" \
                                  "$G_RELEASE" \
                                  "$CRT_GNB_LOAD_ID" \
                                  "$L_TEST_LINE_DESC" \
                                  "$BUILD_URL/artifact/$R_TEST_OUTPUT_DIR/log.html" \
                                  "$CRT_TEST_BRANCH" \
                                  "$CRT_AIRPHONE_VERSION" \
                                  "$CRT_LUASHARK_VERSION" \
                                  "$G_TEST_SCRIPT" \
                                  "$CRT_DRY_RUN" \
                                  "$CRT_NB_EXEC" \
                                  "$CRT_GNB_REPOSITORY"
            exit $?
        else
            echo "***** ERROR : missing of output.xml file --> cannot generate report file"
            exit 1
        fi
    )

    if [ $G_USE_SEND_MAIL ]
    then
        L_MAIL_SUBJECT=$(FormatMailSubject "$L_MAIL_SUBJECT")

        echo "From: $L_SENDER"           > $L_MSG_FILE
        echo "To: $CRT_MAILING_LIST"     >> $L_MSG_FILE
        echo "Cc: "                      >> $L_MSG_FILE
        echo "Subject: $L_MAIL_SUBJECT"  >> $L_MSG_FILE
        echo "Content-type: text/html"   >> $L_MSG_FILE
    fi
    if [ -f $R_TEST_OUTPUT_DIR/ci_report.html ]
    then
        # add the ci_report.html file content to the mail
        cat $R_TEST_OUTPUT_DIR/ci_report.html >> $L_MSG_FILE
    else
        echo -e "<p>" >> $L_MSG_FILE
        echo -e "ERROR : report file could not be generated<br>" >> $L_MSG_FILE
        echo -e "-------------- PLEASE CHECK --------------<br>" >> $L_MSG_FILE
        echo -e "</p>" >> $L_MSG_FILE
    fi

    if [ $G_USE_SEND_MAIL ]
    then
        # use Linux "sendmail" command to send mail
        echo "Sending email"
        cat $L_MSG_FILE | /usr/lib/sendmail -t -oi -f $L_SENDER
    else
        # use "Editable mail" plugin to send mail
        # echo "R_MAIL_SENDER=$L_SENDER" > $R_MAIL_DATA_FILE
        local L_MAIL_CONTENT=`cat $L_MSG_FILE`

        echo "R_MAIL_SUBJECT=$L_MAIL_SUBJECT" > $R_MAIL_DATA_FILE
        echo "R_MAIL_RECIPIENTS=$CRT_MAILING_LIST" >> $R_MAIL_DATA_FILE
        echo "R_MAIL_CONTENT=$L_MAIL_CONTENT" >> $R_MAIL_DATA_FILE
    fi
}

# Mapping between GNB load ID and the ROTTA directory where to store data
# ATTENTION : no "echo", "printf" , ... should be put in this function
# otherwise the output will be incorrect
function MapLoadIdToDirName()
{
# set -xv
    # Load ID should have the format "<load prefix>-ECE+<load suffix>"
    # Ex: 4.2113.532-ECE+180917.354
    local L_LOAD_ID=$1

    # Get the prefix part that can be used to identify the dir name
    # <load prefix>=<p1.p2.p3> --> <p1.p2> are used to indentify the dir name
    local L_LOAD_TYPE=`echo $L_LOAD_ID | cut -d "-" -f 1`
    L_LOAD_TYPE=${L_LOAD_TYPE%.*}

    local L_DIR_NAME=""

    case "$L_LOAD_TYPE" in
        "4.2113")
            L_DIR_NAME="master_cloudbts_l1r3"
            ;;
        "4.42113")
            L_DIR_NAME="b4_cloudbts_l1r3"
            ;;
        "4.3113")
            L_DIR_NAME="master_cloudbts_l2_l1r3"
            ;;
        "4.83")
            L_DIR_NAME="master_classicalbts_l1r3"
            ;;
        "4.833")
            L_DIR_NAME="master_classicalbts_l2_l1r3"
            ;;
        *)
            # by default, use the LOAD_TYPE as directory name
            L_DIR_NAME="$L_LOAD_TYPE"
            ;;
    esac
    echo $L_DIR_NAME
}

# Tranfer test data file (logs and execution data) to ROTTA server
function TransferTestDataToRotta()
{
# set -xv
    Step    "TRANSFER Test Data to Rotta"
    # directory containing data to be sent
    local L_DATA_DIR=$1

    # optional variable to return some information
    local L_OUT_VAR=$2

    local L_ROTTA_LOGIN=$CRT_ROTTA_LOGIN
    local L_ROTTA_PASSWD=$CRT_ROTTA_PASSWD
    local L_ROTTA_SERVER=$CRT_ROTTA_SERVER

    local L_CMD

    # set the default path (this is defined by rotta-mount command and cannot be changed)
    local L_ROTTA_DIR="/mnt/${CRT_ROTTA_LOGIN}/rotta4internal"

    # check if the ROTTA NFS is mounted
    if [ ! -d $L_ROTTA_DIR ]
    then
        # directory missing --> need to mount ROTTA NFS
        # (rotta-mount command was provided by SCM team and installed in /usr/bin by SDE team)

        L_CMD="rotta-mount -m -i"

expect <<- DONE
        set timeout 60
        spawn ssh -o StrictHostKeyChecking=no -o CheckHostIP=no ${L_ROTTA_LOGIN}@${L_ROTTA_SERVER} $L_CMD
        expect "password:" { send "${L_ROTTA_PASSWD}\n" }
        set prompt "#|%|>|\\\$ $"
        expect {
               "Password:" { send "${L_ROTTA_PASSWD}\n" }
               -re \$prompt
        }
        catch wait reason
        exit [lindex \$reason 3]
DONE

        if [ $? -ne 0 ]
        then
            echo "***** ERROR : could not mount ROTTA NFS for transferring data"
            return 1
        fi
    fi

    # set the destination directory where data must be copied to
    
    local L_LOAD_TYPE=`MapLoadIdToDirName $CRT_GNB_LOAD_ID`
    
    local L_SHORT_DEST_DIR="5G/FRT/${L_LOAD_TYPE}/${CRT_GNB_LOAD_ID}/${G_SITE_ID}"
    
    local L_DEST_DIR="${L_ROTTA_DIR}/${L_SHORT_DEST_DIR}"

    # check if the directory exists
    if [ ! -d $L_DEST_DIR ]
    then
        # directory missing --> create it
        L_CMD="mkdir -p $L_DEST_DIR"

expect <<- DONE
        set timeout 60
        spawn ssh -o StrictHostKeyChecking=no -o CheckHostIP=no ${L_ROTTA_LOGIN}@${L_ROTTA_SERVER} $L_CMD
        expect "password:"
        send "${L_ROTTA_PASSWD}\n"
        expect eof
        catch wait reason
        exit [lindex \$reason 3]
DONE

        if [ $? -ne 0 ]
        then
            echo "***** ERROR : could not create ROTTA directory $L_DEST_DIR"
            return 1
        fi
    fi

    # transfer the data file to the destination

expect <<- DONE
        set timeout 60
        spawn scp -o StrictHostKeyChecking=no -o CheckHostIP=no -r $L_DATA_DIR/. ${L_ROTTA_LOGIN}@${L_ROTTA_SERVER}:$L_DEST_DIR
        expect "password:"
        send "${L_ROTTA_PASSWD}\n"
        expect eof
        catch wait reason
        exit [lindex \$reason 3]
DONE

    local L_RET_CODE=$?

    # check if the (short) destination dir must be return to the caller
    if [ $L_OUT_VAR ]
    then
        eval $L_OUT_VAR=\$L_SHORT_DEST_DIR
    fi

    if [ $L_RET_CODE -ne 0 ]
    then
        echo "***** ERROR : could not upload test data to ROTTA directory $L_DEST_DIR"
        return 1
    else
        echo "***** Test data successfully uploaded to ROTTA directory $L_DEST_DIR"
        return 0
    fi

}

# main function
function main()
{
set -xv
    init
    local L_ROTTA_DEST_DIR
    # download tests sources into G_ROBOT_DIR
    DownloadSources $G_DOWNLOAD_SRC $G_ROBOT_DIR

    # run tests
    RunTest
    G_TEST_RESULT=$?

    # uploade tests data to ROTTA
    if [ "$SEND_TEST_DATA" == "true" ]
    then
        # L_ROTTA_DEST_DIR will contain the destination directory on ROTTA server
        TransferTestDataToRotta $R_TEST_OUTPUT_DIR L_ROTTA_DEST_DIR
    fi

    # send tests report
    SendReport $L_ROTTA_DEST_DIR

    # exit with test result
    return $G_TEST_RESULT
}

main

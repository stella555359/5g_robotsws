#!/bin/bash
# Get user name
User=$(whoami)
DefaultRunRobotPath="$HOME/tools"

# Set temporary trace file path, name of configuration file, Name of project dir
TraceFile="/tmp/RunRobot.$User.trace"
ConfigFileName="RunRobot.cfg"
ProjectName="robotws"
RelConfigPath="testsuite/Paris/ResourcesSWENG/tools"
TracesPath="/ebs/$User/TRACES"
TopologyStr=""
EnbBuild=""
Deploy=""
Sherpa=false
SharkTool=""
PythonPath=""

#teardown handler
#trap ctrl_c INT
function ctrl_c() {
        echo "Run teardown ...
         -connect to Asik gnb ..
         -restore swconfig.txt
         -connect to WTS
         -resore AirphoneXml
         -.....             "
}

# ---------------------------------------------------------------------------------------------------------------------
# Generic tools
# ---------------------------------------------------------------------------------------------------------------------
function initLog()   {
    TimeStamp=$(date +"%Y%m%d_%H%M%S");
    if [ -f $TraceFile ]; then
        rm $TraceFile;
    fi;
    touch $TraceFile;
}
function pause       { read -p "<Press any key to continue>"; }
function ERROR()     { INFO  "ERROR:$1"; }
function FATAL()     { ERROR "$1";exit; }
function show()      { str=$(printf "    %-20s : " "$1";  printf "$2\n";); INFO "$str"; }
function INFO()      { dt=$(date +"%Y/%m/%d %H:%M:%S"); printf "%s\n" "$1"; echo "$dt:$1" >> $TraceFile; }
function traceLine() { str=$(printf '=%.0s' {1..78});INFO $str; }

# Python Path
PythonPath=$(which python)
INFO "PYTHON PATH=[$PythonPath]"

# Retrieve system cmd and path
CommandLine="$0 $@"
ExecPath=$(pwd)
pushd $(dirname $0) > /dev/null
ScriptPath=$(pwd)
popd > /dev/null
ProjectRoot=$(echo $ScriptPath | sed -e "s/$ProjectName.*/$ProjectName/g")

# URL for Luashark
AF_WftSourceChina="https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-central-public-local/System_Release"
AF_WftSourceWft="https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release"
SBTS_WftSource="https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build"
Qcow2Nameprefix="AirFrameVirtualized"

# Temporary files
TestCaseListFile="/tmp/TestCases.$User.txt"

# Other variables
PauseMode=true
DryMode=true
TimestampUsed=true
ListTestSuite=()

#---- Color variables --------------------------------------------------------------------------------------------------
BLACK='\033[30m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PINK='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_PINK='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'
NORMAL='\033[0m'

function show_help () {
    cat <<EOF
Description:
   Tool to run robot with some default settings as set in RunRobot.cfg
   Some parameters may be override by explicit arguments
   Some checks are performs : test name, excluded tags, config directory,...
   We can launch 1 or more Test suite (a coma list may be set for -s option)
   or we can launch 1 or more tests in 1 Test suite.
   - Version argument is used for luashark specification
   - Build argument is used to specify that TL is an UTE one
   At least one of the 2 arguments (version, build) is required
   If only Build is set, luashark will be retrieved (as for UTE TL) in /opt/luashark
   if Version is set, luashark will be retrieved from WFT and downloaded in /home/<user>/tools/luashark

   For --test option, we can :
   - set nothing (no use of -t) : all tests from test suite will be executed (except exclude ones: see --ex option)
   - set 1 test  (-t <test>)    : only this test will be executed
   - set a coma list of tests   : -t t1,t2,t3
   - set an interval of tests   : -t ..t1 (all until t1), -t t1.. (all from t1), -t t1..t2 (from t1 to t2)
   Note : spaces are not allowed in test naming (bash restriction), so replace them with "_"

Options:
   ===== General =====================
   -f | --file                 : OPT  : Select config file name in $DefaultRunRobotPath  (Default:$ConfigFileName)
   -h | --help                 : OPT  : Show help
        --noPause              : OPT  : Avoid keyboard pause before launching Robot command
        --nt                   : OPT  : No timestamp used in naming of result directory
   -p | --python               : OPT  : Set python path (by default, get thru a which python command)

   ===== Config ======================
   -l | --loc    <Location>    : OPT  : Set path of TL config  (from robotws)   Default:$LocationName
   -c | --cfg      <config>    : OPT  : Set Configuration to load               Default:$ConfigName
   -w | --wft   <WftSource>    : OPT  : Set source for QCow2 (ESPOO or CHINA)   Default:$WftSource
   -v | --version <version>    : OPT  : Set luashark version (format:x.yyy.zzz) Default:$Version
   -b | --build <ENB_BUILD>    : OPT  : Set ENB BUILD (format:5G_... or SBTS...)
   -d | --deploy <Deploiement> : OPT  : Specify for SANSA tests if we want to have a SA or NSA deploiment
        --topo <topoString>    : OPT  : Set Topology String (CLOUD_5G...)       Default:$TopologyStr
        --sherpa               : OPT  : Activate Sherpa option                  Default:$Sherpa
        --shark <toolName>     : OPT  : Set decode tool (LUA_SHARK or MC_SHARK) Default:$SharkTool
   ===== Test selection ==============
   -k | --kind <KindOftest>    : OPT  : Select Relative path to suites          Default:$KindSuite
   -s | --suite <SuiteTest>    : OPT  : Select test suite file name (or list)   Default:$SuiteTest
   -t | --test   <testName>    : OPT  : Select Robot test (or list or interval) Default:$TestName
   -e | --ex    <exludeTag>    : OPT  : Exclude a coma list of tag              Default:$ExcludeTag

   ===== Mode ========================
   -r | --real                 : OPT  : Active REAL mode (desactive DRYRUN)

Examples :
    ./RunRobot.sh -c 7_20_CLOUD5GPSECETL09 -w ESPOO -v 0.135.418 -k RRM/ECE/UE_Call_Setup/5GC000636-D -s Essai.robot -t 5GC000636_TestCase1 -e CREATE_STACK,INSTALL  --nt
    ./RunRobot.sh -s Essai.robot,Essai2.robot

Examples of topology:
    CLOUD_5G_KL_AP_NSA_FS_CMWV_TDD,    CLOUD_5G_BL_AP_NSA_FS_CMWV_TDD,
    CLOUD_5G_LO_AP_NSA_L1B_ECPRI_CMWV, CLOUD_5G_BL_AP_SANSA_FS_CPRI_CMWV_TDD
    ...
EOF
exit ${no_error}
}

#----------------------------------------------------------------------------------------------------
# Function that analyze arguments
#----------------------------------------------------------------------------------------------------
FirstArgParsing=true
function analyze_arguments () {
    if $FirstArgParsing; then INFO "Command : $CommandLine"; fi
    getopt_results=`getopt -s bash \
        -o \ h,l:,c:,w:,v:,k:,s:,t:,e:,r,f:,b:,d:,p: \
        --long help,loc:,cfg:,wft:,version:,kind:,suite:,test:,ex:,real,noPause,nt,file,topo:,build:,deploy:,sherpa,shark:,python:  -- "$@"`

    if test $? != 0; then
        echo "unrecognized option"
        exit ${error_bad_option}
    fi
    eval set -- "$getopt_results"
    argument_str=""

    while true
    do
        case "$1" in
        -h | --help)
            if ! $FirstArgParsing; then show_help; fi
            shift 1;
        ;;
        -l | --loc)
            LocationName=$2
            argument_str="$argument_str LOCATION=$LocationName, "
            shift 2;
        ;;
        -v | --version)
            Version=$2
            argument_str="$argument_str VERSION=$Version, "
            shift 2;
        ;;
        -c | --cfg)
            ConfigName=$2
            argument_str="$argument_str CONFIG=$ConfigName, "
            shift 2;
        ;;
        -s | --suite)
            SuiteTest=$2
            argument_str="$argument_str TEST_SUITE=$SuiteTest, "
            shift 2;
        ;;
        -t | --test)
            TestName=$2
            argument_str="$argument_str TEST_NAME=$TestName, "
            shift 2;
        ;;
        -k | --kind)
            KindSuite=$2
            argument_str="$argument_str KIND=$KindSuite, "
            shift 2;
        ;;
        -e | --ex)
            ExcludeTag=$2
            argument_str="$argument_str EXCLUDE=$ExcludeTag, "
            shift 2;
        ;;
        -w | --wft)
            WftSource=$2
            argument_str="$argument_str WFT_SOURCE=$WftSource, "
            shift 2;
        ;;
        -f | --file)
            ConfigFileName=$2
            argument_str="$argument_str CFG_FILE=$ConfigFileName, "
            shift 2;
        ;;
        --topo)
            TopologyStr=$2
            argument_str="$argument_str TOPOLOGY=$TopologyStr, "
            shift 2;
        ;;
        -b | --build)
            EnbBuild=$2
            argument_str="$argument_str ENB_BUILD=$EnbBuild, "
            shift 2;
        ;;
        -d | --deploy)
            Deploy=$2
            argument_str="$argument_str DEPLOY=$Deploy, "
            shift 2;
        ;;
        -p | --python)
            PythonPath=$2
            argument_str="$argument_str PYTHON_PATH=$PythonPath, "
            shift 2;
        ;;
        --sherpa)
            Sherpa=true
            argument_str="$argument_str SHERPA=$Sherpa, "
            shift 1;
        ;;
        --shark)
            SharkTool=$2
            argument_str="$argument_str SHARK_TOOL=$SharkTool, "
            shift 2;
        ;;
        -r | --real)
            DryMode=false
            argument_str="$argument_str MODE=REAL, "
            shift 1;
        ;;
        --noPause)
            PauseMode=false
            argument_str="$argument_str PAUSE=$PauseMode, "
            shift 1;
        ;;
        --nt)
            TimestampUsed=false
            argument_str="$argument_str TIMESTAMP_USED=$TimestampUsed, "
            shift 1;
        ;;
        --)
            shift
            break
        ;;
        *)
            INFO"$0: unparseable option $1"
            exit ${error_bad_option}
        ;;
        esac
    done
    if $FirstArgParsing; then  INFO "Argument:$argument_str"; fi
    FirstArgParsing=false
}

#----------------------------------------------------------------------------------------------------
# Function that check a directory exists, then show list of them is entry is not correct
#----------------------------------------------------------------------------------------------------
function checkDir() {
    local root=$1   # Root path to directory to test
    local file=$2   # Name of file to test
    local name=$3   # Title of kind of data expected
    path=$root/$file
    # If directory exists, no pb ; trace then return
    if [ -d "$path" ]; then INFO "$name:Directory $path exists"; return; fi
    # Otherwise, get list of available entries and exit
    ERROR "Unable to find dir $path for location"
    INFO "Select one of them, and relaunch command"
    IFS=$'\n'
    for file in $(cd $root;ls -1); do
        INFO "    $file"
    done
    exit
}

#----------------------------------------------------------------------------------------------------
# Function that set all parameters required to build robot command, upon arguments of command
#----------------------------------------------------------------------------------------------------
function setParameters () {
    # Replace "/" with "." in Kind Suite
    ShortKindSuite=$(echo $KindSuite | sed -e "s/\//./g")

    # Check and set location
    checkDir "$ProjectRoot" "$LocationName" "Location"
    ConfigRoot="$ProjectRoot/$LocationName"

    # Check and set config dir
    checkDir "$ConfigRoot" "$ConfigName" "Config"
    ConfigPath="$ConfigRoot/$ConfigName"

    # Set AF PATH
    setAFPath

    # Check and set test dir
    EtRelPath="testsuite/Paris/RRM/ET"
    checkDir "$ProjectRoot/$EtRelPath" "$KindSuite" "Kind"
    TestRoot="$ProjectRoot/$EtRelPath/$KindSuite"

    # Set run option upon dry or not
    if $DryMode;then
        RunModeStr="${BG_GREEN}${BLACK}DRY Run${NORMAL}";
        ModeStr="Dry"
        DryModeCmd=" --dryrun"
    else
        RunModeStr="${BG_RED}${BLACK}REAL Run on Target${NORMAL}";
        ModeStr="Real"
        DryModeCmd=""
    fi

    # Set Config path, result path
    LogPath="$TracesPath"
    LogFile="$LogPath/RunRobot.log"

    # Set exclude option
    if [ -z $ExcludeTag ]; then ExcludeStr=""; else
        IFS=','
        for field in $ExcludeTag;do
            ExcludeStr="$ExcludeStr -e '$field'"
        done
    fi
}

#----------------------------------------------------------------------------------------------------
# Function that set the AF_PATH variable upon input arguments
#----------------------------------------------------------------------------------------------------
function setAFPath() {
    AF_PATH=""
    if [ ! -z "$Version" ]; then
        if [[ "$Version" == "SBTS"* ]]; then
            prefix=$(echo "$Version" | cut -d '_' -f1)
            AF_PATH="$SBTS_WftSource/$prefix/${Version}_luashark.zip"
            echo "==> AF_PATH=[$AF_PATH]"
        else
            if [[ $WftSource == "ESPOO" ]]; then AF_PATH="$AF_WftSourceWft/$Version/luashark-$Version.zip";  fi
            if [[ $WftSource == "CHINA" ]]; then AF_PATH="$AF_WftSourceChina/$Version/luashark-$Version.zip";  fi
        fi
        if [ -z "$AF_PATH" ]; then FATAL "WFT Source [$WftSource] is not allowed. Should be one of : ESPOO, CHINA"; fi
    fi
}

#----------------------------------------------------------------------------------------------------
# Function that check that one and only one argument between version and ENB_BUILD is entered
#----------------------------------------------------------------------------------------------------
function checkVersion() {
    prefix="VERSION=$Version ENB_BUILD=$EnbBuild"
    if [ -z "$Version" ] && [ -z "$EnbBuild" ]; then
        error="Both variables are empty. use -v or -b option to specify at least one of them"
    fi
    if [ -z "$Version" ]; then
        FinalVersion="$EnbBuild"
    else
        FinalVersion="$Version"
    fi
    if [ ! -z "$error" ]; then
        FATAL "$prefix:$error"
    fi
    TarFile=$ConfigName.$ShortKindSuite.$FinalVersion.$TimeStamp.tgz
}

#----------------------------------------------------------------------------------------------------
# Function that check test suite existency
#----------------------------------------------------------------------------------------------------
function checkTestPath() {
    # At least one Test suite shoule be selected
    if [ -z "$SuiteTest" ]; then FATAL "No test suite were selected. Use -t option for the same"; fi
    # Count number of specified test suite
    NbSeparator=$(IFS=' '; awk -F"," '{print NF-1}' <<< $SuiteTest)
    let NbTestSuite=NbSeparator+1

    # Compute each test path
    TestPath=""
    IFS=',' read -r -a field <<< "${SuiteTest}"
    for ((nb=0;nb<$NbTestSuite;nb++));do
        ListTestPath[$nb]=$TestRoot/${field[$nb]};
        if [ -f ${ListTestPath[$nb]} ];then
            INFO "File ${ListTestPath[$nb]} exists";
            TestPath="$TestPath ${ListTestPath[$nb]}"
        else
            # If not found, collect list of available robot files
            IFS=$'\n'
            ERROR "Unable to find test suite file : ${ListTestPath[$nb]}"
            INFO "Available Sub directories are:"
            listFileStr=$(cd $TestRoot;ls)
            for file in $listFileStr;do
                if [ -d $TestRoot/$file ]; then INFO "  $file"; fi
            done
            listFileStr=$(cd $TestRoot;ls *.robot 2>&1)
            if [[ "$listFileStr" != *"No such file"* ]]; then
                INFO "Available Robot scenario are:"
                for file in $listFileStr;do
                    INFO "  $file"
                done
            fi
            exit
        fi
    done
    # Set Title for test
    if [ $NbTestSuite -eq 1 ]; then TitleTest=$SuiteTest; else TitleTest=$KindSuite; fi
}

#----------------------------------------------------------------------------------------------------
# Function that parse a robot file and get all test cases
#----------------------------------------------------------------------------------------------------
function build_tc() {
    startTest=false
    rm -Rf $TestCaseListFile
    IFS=$'\n'
    for l in $(cat ${ListTestPath[0]});do
        # Taking only line after "*** test cases ***" and before next "***"
        if $startTest;then
            # Next "***" section : no more in test list
            if [[ $l == "***"* ]]; then startTest=false; else
                # Taking only line staring in first colon
                if [[ $l != "  "* ]]; then
                    # removing end spaces and changing all spaces with "_"
                    str=$(echo "$l" | cut -d "#" -f1 | sed -e "s/ *$//g" | sed -e "s/ /_/g" | sed -e "s/\r//g")
                    if [ ! -z "$str" ]; then echo "$str" >>$TestCaseListFile; fi
                fi
            fi
        fi
        # Entering tests cases section
        if [[ $l == "*** Test Cases ***"* ]]; then startTest=true; fi
    done
}

#----------------------------------------------------------------------------------------------------
# Function that check test case names in argument (-t ...) are valid
#----------------------------------------------------------------------------------------------------
function check_tc_from_arg() {
    local listExtrema=$(echo $TestName | sed -e "s/\.\./,/g" | sed -e "s/^,//g" | sed -e "s/,$//g" | tr -s ',')
    IFS=',' read -r -a array <<< "$listExtrema"
    for tc in "${array[@]}"; do
        found=false
        for line in $(cat $TestCaseListFile); do
            if [[ $tc == "$line" ]]; then
                INFO "Test $tc found"
                found=true
                break;
            fi
        done
        if ! $found;then
            ERROR "Test $tc not found in ${ListTestPath[0]}";
            INFO "Test cases in ${ListTestPath[0]} are:"
            for line in $(cat $TestCaseListFile); do
                INFO "    $line"
            done
            exit
        fi
    done
}
#----------------------------------------------------------------------------------------------------
# Function that check that the test name eventually selected is belonging to test suite
#----------------------------------------------------------------------------------------------------
function checkTestName() {
    NbTest=0
    # If no test case selected, no filtering to perform
    if [ -z $TestName ]; then return; fi
    # if several test suite are selected, no test case is expected
    if [ $NbTestSuite -gt 1 ]; then FATAL "As several test suite were selected, no test case is allowed !"; fi

    # a TC was selected : get list of TC in selected test suite
    build_tc
    check_tc_from_arg
    # Build a list of test upon -t argument
    if   [[ "$TestName" ==  ".."* ]];then TestList=$(get_tests_from_interval ""        $TestName);
    elif [[ "$TestName" == *".."  ]];then TestList=$(get_tests_from_interval $TestName ""       );
    elif [[ "$TestName" == *".."* ]];then TestList=$(get_tests_from_interval $TestName $TestName);
    else                                  TestList=$TestName;
    fi
    IFS=',' read -r -a array <<< "$TestList"
    NbTest=${#array[@]}
    INFO "List of test:$TestList Number of test=$NbTest"
    for tc in "${array[@]}"; do
        TestNameStr="$TestNameStr -t $tc"
    done
}

#----------------------------------------------------------------------------------------------------
# Function that analyze argument as an interval and compute list of tests
#----------------------------------------------------------------------------------------------------
function get_tests_from_interval() {
    local __start=$1
    local __end=$2
    if [ -z "$__start" ]; then __start=$(head -1 $TestCaseListFile); fi
    if [ -z "$__end"   ]; then __end=$(tail -1 $TestCaseListFile); fi
    __start=$(echo $__start | sed -e "s/\.\..*$//g")
    __end=$(echo $__end | sed -e "s/^.*\.\.//g")
    inInterval=false
    local listTC=""
    for line in $(cat $TestCaseListFile); do
        if $inInterval; then
            listTC="$listTC,$line"
        else
            if [[ "$line" == "$__start" ]]; then listTC=$__start; inInterval=true; fi
        fi
        if [[ "$line" == "$__end" ]]; then inInterval=false; fi
    done
    echo "$listTC"
}

#----------------------------------------------------------------------------------------------------
# Function that check selected tags are existing in test suite
#----------------------------------------------------------------------------------------------------
function checkTags() {
    # Build list of TAGS in test suite
    tagFile="/tmp/tags.$User.txt"
    echo "" > $tagFile
    INFO "NbTestSuite=$NbTestSuite"
    for ((i=0;i<NbTestSuite;i++));do
        grep -i "\[TAGS\]" ${ListTestPath[$i]}>> $tagFile
        INFO "FOR TAG : ${ListTestPath[$i]}"
    done
    list=","
    for line in $(cat $tagFile); do
        IFS=" "
        for word in $line;do
            word=$(echo -e "$word" | sed -e "s/\n//g")
            if [[ $word == *"["* ]]; then continue; fi
            if [[ $list != *",$word,"* ]]; then list="$list$word,"; fi
        done
    done
    shortList=$(echo "$list" | sed -e "s/^,//g" | sed -e "s/,$//g")
    IFS=","
    # Parsing list of selected tags, and check for each that it is in shortList
    for tag in $ExcludeTag;do
        if [[ $list != *",$tag,"* ]]; then FATAL "Unable to find tag $tag in list : $shortList"; fi
    done
    INFO "Tags [$ExcludeTag] were checked"
}

#----------------------------------------------------------------------------------------------------
# Function that check all input parameters
#----------------------------------------------------------------------------------------------------
function checkParameter() {
    checkVersion
    checkTestPath
    checkTestName
    checkTags
}

#----------------------------------------------------------------------------------------------------
# Function that build robot command to launch
#----------------------------------------------------------------------------------------------------
function buildRobotCommand() {
    # Check if python path is correct
    if [ ! -f "$PythonPath" ]; then
        FATAL "Your path to python [$PythonPath] is not correct"
    fi
    VersionStr=""
    if [ ! -z "$EnbBuild" ]; then
        VersionStr="-v ENB_BUILD:$EnbBuild"
    fi
    if [ ! -z "$Version" ]; then
        VersionStr="$VersionStr -v AF_PATH:$AF_PATH"
    fi
    DeployStr=""
    if [ ! -z "$Deploy" ]; then
        DeployStr=" -v deploy:$Deploy"
    fi
    DebugStr="-L DEBUG -b debug.log"
    TopoOption=""
    if [ ! -z "$TopologyStr" ]; then
        TopoOption="-v topo:$TopologyStr"
    fi
    SherpaOption=""
    if $Sherpa; then
        SherpaOption="-v hire_a_sherpa:True"
    fi
    SharkToolOption=""
    if [ ! -z "$SharkTool" ]; then
        SharkToolOption="-v SharkTool:$SharkTool"
    fi

    RobotCmd="$PythonPath -m robot $DryModeCmd -V $ConfigPath $VersionStr $TopoOption $DeployStr $SherpaOption $SharkToolOption $DebugStr -N $TitleTest -d $ResultPath $ExcludeStr $TestNameStr $TestPath"
}

#----------------------------------------------------------------------------------------------------
# Function that compute path of results upon context
#----------------------------------------------------------------------------------------------------
function buildResultPath() {
    # Basic root to results
    ResultPath="$TracesPath/$ShortKindSuite/$ConfigName/$FinalVersion/$ModeStr/"
    RelResultPath=""
    # Add timestamp only if required
    if $TimestampUsed; then RelResultPath="$RelResultPath${TimeStamp}."; fi
    # Add suite name or kind suite upon nb of test suite selected
    if [ $NbTestSuite -gt 1 ]; then
        RelResultPath="${RelResultPath}$ShortKindSuite";
    else
        name=$(basename -- ${ListTestPath[0]} )
        RelResultPath="${RelResultPath}${name%.*}"
    fi
    ResultPath="$ResultPath$RelResultPath"
    ResultFile="$ResultPath/RunRobot.trace"
}

#----------------------------------------------------------------------------------------------------
# Function that display all selected and computed parameters for tests
#----------------------------------------------------------------------------------------------------
function show_test_suite() {
    show "Suite of test  [-s]"    ${ListTestPath[0]}
    for ((i=1;i<NbTestSuite;i++));do show " "    ${ListTestPath[$i]}; done
}

function showContext() {
    traceLine
    INFO "CONFIG: ----------------------------------------------------------------------"
    show "RunRobot.cfg       "    $RobotConfigfile
    show "Python Path        "    $PythonPath
    show "Location       [-l]"    $LocationName
    show "Config name    [-c]"    $ConfigName
    show "WFT Source     [-w]"    $WftSource
    show "Version        [-v]"    $Version
    show "ENB BUILD      [-b]"    $EnbBuild
    show "Deploy mode    [-d]"    $Deploy
    show "Sherpa   [--sherpa]"    $Sherpa
    show "SharkTool [--Shark]"    $SharkTool
    show "Config Path        "    $ConfigPath
    show "AF_PATH            "    "$AF_PATH"
    show "Topology   [--topo]"    $TopologyStr

    INFO "TEST: ------------------------------------------------------------------------"
    show "Kind of test   [-k]"    "$KindSuite"
    show_test_suite
    show "Test name      [-t]"    "$TestName"
    if [ "$NbTest" -gt 1 ]; then
    show "Test list          "    "$NbTest tests : $TestList"
    fi
    show "EXCLUDE tag    [-e]"    "$ExcludeTag"
    show "Run mode       [-r]"    "$RunModeStr"

    INFO "RESULTS:----------------------------------------------------------------------"
    show "Result Path        "    $ResultPath
    show "Result file        "    $ResultFile
    show "Tar file           "    $TarFile

    traceLine
    show "Robot CMD          "    "$RobotCmd"
    traceLine
    if $PauseMode;then pause; fi
}

#----------------------------------------------------------------------------------------------------
# Function that launch robot command and redirect traces
#----------------------------------------------------------------------------------------------------
function launchCommand() {
    # Create path for results
    mkdir -p $ResultPath
    mkdir -p $LogPath
    touch $LogFile

    # Put first part of traces in global log file
    cat  $TraceFile >> $LogFile
    mv $TraceFile $ResultFile

    # Launch robot cmmand and append next trace in contextual result file
    TraceFile=$ResultFile
    ExportCmd="export ftp_proxy= && export http_proxy= && export https_proxy= && export HTTP_PROXY= && export HTTPS_PROXY= && export | grep -i proxy"
    ExportPathCmd="export PYTHONPATH=$PYTHONPATH:$ProjectRoot:$ProjectRoot/resources/python_libs && export | grep PYTHONPATH"
    eval "$ExportCmd && $ExportPathCmd && $RobotCmd 2>&1 | tee -a $ResultFile"

    # Launch tar command
    INFO "Generating $ResultPath/$TarFile"
    res=$(cd $ResultPath/..;tar -cvzf $TarFile $RelResultPath)
    mv $ResultPath/../$TarFile  $ResultPath
}

#----------------------------------------------------------------------------------------------------
# Function that retrieve config file
#----------------------------------------------------------------------------------------------------
function getRobotConfigFile() {
    # Attempt to find a RunRobot.cfg in /home, otherwise in git
    RobotConfigfile="$DefaultRunRobotPath/${ConfigFileName}"
    if [ ! -f  "$RobotConfigfile" ];then
        RobotConfigfile="$ProjectRoot/$RelConfigPath/${ConfigFileName}"
        if [ ! -f  "$RobotConfigfile" ];then
            INFO "List of files in $DefaultRunRobotPath:"
            for file in $(cd $DefaultRunRobotPath;ls -1); do
                INFO "    $file"
            done
            FATAL "No $ConfigFileName file found";
        fi
    fi
}

#----------------------------------------------------------------------------------------------------
# MAIN
#----------------------------------------------------------------------------------------------------
initLog                 # For trace file init
analyze_arguments $@    # First analysis to catch config file
getRobotConfigFile
source "$RobotConfigfile"
analyze_arguments $@    # Second analysis to override config file by arguments
setParameters
checkParameter
buildResultPath
buildRobotCommand
showContext
launchCommand

#!/bin/bash

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

ProjectName="robotws"
# Retrieve system cmd and path
CommandLine="$0 $@"
ExecPath=$(pwd)
pushd $(dirname $0) > /dev/null
ScriptPath=$(pwd)
popd > /dev/null
ProjectRoot=$(echo $ScriptPath | sed -e "s/$ProjectName.*/$ProjectName/g")

# Get user name
User=$(whoami)

LocationName="ParisSaclay"                    # Name of location for config files
RootConfigName="7_20"
ConfigRoot="$ProjectRoot/config/$LocationName"
TracesDir="CI"                                # Name of directory for traces. (will be in /ebs/$user)
ResRootRootPath="/ebs/$User/$TracesDir"       # Very root path to results
DebugOption="-L DEBUG -b debug.log"           # Robot debug option
OtherOption="-v delete_stack:ALL"             # Other options for Robot

# Main variables
PauseMode=true          # Toogle pause mode
#TimestampUsed=true      # Toogle for use of timestamp in traces dir
TimeStamp=""            # Time stamp string
Version=""              # Version of load
AfPath=""               # AF Path for version download
TLName=""               # Name of TL
DryMode=true            # Toogle rela mode / dry run
RunModeStr=""           # Colored string for display of mode
ModeDir=""              # Directory name upon mode
DryModeCmd=""           # Robot option upon exec mode
ArgSeqFiles=""          # Sequence files set as argument
NbExec=1                # Number of times execution should be done
CiMode=false            # Ci mode toogle : to run 1 unique robot command for all instead of 1 robot command per test suite
AllSeq=false            # Toogle to select ALL sequence files
QcOption=false          # Toogle option to launch qc at the end of tests
QcBranch=false          # Toogle option to compute gNB load branch and update QC depending on branch
LuasharkVersion=""      # Luashark version to be used (in case not the same as gnb Load)
NbDay=60                # Number of day after which logs should be removed
IncludeTagList=""       # List of tags to include
ExcludeTagList=""       # List of tags to exclude

# Set temporary trace file path, name of configuration file, Name of project dir
SCRIPT_NAME="Launch"
TRACE_FILE_NAME="console.$User.log"
TraceFile="/tmp/$TRACE_FILE_NAME";
PROJECT_NAME="robotws"
REL_CONFIG_PATH="testsuite/CRT/ParisSaclay/tools"

# Directories names
TL_DIR_NAME="TL"
SEQ_DIR_NAME="Sequences"
TEST_SUITE_DIR_NAME="testsuite"

declare -A TestSuite
SEQ=1
FEAT=2
NAME=3
LOC=4
QC=5
DIAG=6
NbTS=0

# Temporary files
TestCaseListFile="/tmp/TestCases.$User.txt"

# URL for QCow2
WftRootUrl="https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release"
Qcow2Nameprefix="AirFrameVirtualized"

# ---------------------------------------------------------------------------------------------------------------------
# Generic tools
# ---------------------------------------------------------------------------------------------------------------------
function initLog()   { TimeStamp=$(date +"%Y%m%d_%H%M%S"); if [ -f $TraceFile ];then rm $TraceFile; fi
                       touch $TraceFile;}
function pause       { read -p "<Press any key to continue>"; }
function INFO()      { dt=$(date +"%Y/%m/%d %H:%M:%S"); printf "$1\n"; echo "$dt:$1" >> $TraceFile; }
function ERROR()     { INFO "ERROR:$1"; }
function FATAL()     { INFO "FATAL_ERROR:$1";exit -1; }
function traceLine() { INFO "==========================================================================================="; }
function show1()     { str=$(printf "%-35s : " "$1";      printf "$2\n";); INFO "$str"; }
function show2()     { str=$(printf "    %-31s : " "$1";  printf "$2\n";); INFO "$str"; }
function high_line() { title_line=$(printf "%-128s" "$1");INFO "$2$title_line${NORMAL}";}
function big_bar()   {
    line=$(printf '~%.0s' {1..128})
    high_line "$line" "${BG_CYAN}${BLACK}"
    high_line "$1" "${BG_CYAN}${BLACK}"
    high_line "$line" "${BG_CYAN}${BLACK}"
}

# ---------------------------------------------------------------------------------------------------------------------
# HELP
# ---------------------------------------------------------------------------------------------------------------------
function show_help () {
    cat <<EOF
Description:
   Tool to run several robot scripts upon a particular sequence
   Version (-v) and TL Name (-t) arguments are mandatory
   Version is used to design naming of output path
   A sequence file is a suite of feature path, each feature path embedding a list of test suite
   robot files
   List of sequence files may be set thru -s argument thanks to a comma list
   for instance, -s NON_REG_NOMINAL.seq,1097.seq
   Option -s also support directly some robot files. Then, relative path from testsuite should be provided

Options:
   ===== General =====================
   -h | --help                 : OPT  : Show help
        --noPause              : OPT  : Avoid keyboard pause before launching Robot command

   ===== Config ======================
   -v | --version   <version>  : MAND : Set version to load/run
   -t | --tl         <TLName>  : MAND : Set TL Name
   -s | --seq  <SequenceFile>  : MAND : Set list of sequence file/robot files to execute
   -n | --nb         <Number>  : OPT  : Set number of times list of sequence should be executed
   -w | --wft        <WftURL>  : OPT  : Set root URL for WFT access
   -a | --all                  : OPT  : Take ALL sequence files from Sequences/ dir
   -l | --lua <LuasharkVersion>: OPT  : Version of luashark to be used in case different from gNB
   -i | --in    <TagsCommaList>: OPT  : Set a list of tags to include
   -e | --ex    <TagsCommaList>: OPT  : Set a list of tags to exclude

   ===== Mode ========================
   -r | --real                 : OPT  : Active REAL mode (desactive DRYRUN)
        --ci                   : OPT  : CI mode (to run one robot command for all tests suites
        --qc                   : OPT  : Activate script to update QC
        --br                   : OPT  : To used with --qc, depending on gNB load, compute branch and update QC according to branch

Examples :
    ./$SCRIPT_NAME.sh -v 0.1351.1352  -t 7_20_CLOUD5GPSECETL09  -s 1037_TDD_FR1.seq,RRM/ECE/UE_Call_Setup/5GC000636-D/5GC000636-D_CloudTestCases.robot -r --noPause
EOF
exit ${no_error}
}

#----------------------------------------------------------------------------------------------------
# Function that analyze arguments
#----------------------------------------------------------------------------------------------------
function analyze_arguments () {
    getopt_results=`getopt -s bash \
        -o \ h,v:,t:r,s:,n:,w:,a,l:,i:,e:, \
        --long help,version:,tl:,real,noPause,seq:,nb:,ci,wft:,all,qc,br,lua:,in:,ex:,  -- "$@"`

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
            show_help
            shift 1;
        ;;
        -v | --version)
            Version=$2
            argument_str="$argument_str VERSION=$Version, "
            shift 2;
        ;;
        -t | --tl)
            TLName=$2
            argument_str="$argument_str TL_NAME=$TLName, "
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
        -s | --seq)
            ArgSeqFiles=$2
            argument_str="$argument_str SEQ_FILES=$ArgSeqFiles, "
            shift 2;
        ;;
        -n | --nb)
            NbExec=$2
            argument_str="$argument_str NB_EXEC=$NbExec, "
            shift 2;
        ;;
        --ci)
            CiMode=true
            argument_str="$argument_str CI_MODE=$CiMode, "
            shift 1;
        ;;
        --qc)
            QcOption=true
            argument_str="$argument_str QC=$QcOption, "
            shift 1;
        ;;
        --br)
            QcBranch=true
            argument_str="$argument_str QC_BRANCH=$QcBranch, "
            shift 1;            
        ;;        
        -w | --wft)
            WftRootUrl=$2
            argument_str="$argument_str WFT_URL=$WftRootUrl, "
            shift 2;
        ;;
        -a | --all)
            AllSeq=true
            argument_str="$argument_str ALL_SEQ=$AllSeq, "
            shift 1;
        ;;
        -l | --lua)
            LuasharkVersion=$2
            argument_str="$argument_str LUASHARK=$LuasharkVersion, "
            shift 2;
        ;;
        -i | --in)
            IncludeTagList=$2
            argument_str="$argument_str WFT_URL=$IncludeTagList, "
            shift 2;
        ;;
        -e | --ex)
            ExcludeTagList=$2
            argument_str="$argument_str WFT_URL=$ExcludeTagList, "
            shift 2;
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
    show2 "Bash command"        "$CommandLine"
    show2 "Argument"            "$argument_str"
}

#----------------------------------------------------------------------------------------------------
# Function that checks that mandatory arguments are properly set
#----------------------------------------------------------------------------------------------------
function check_mandatory_arguments() {
    # Check on version
    if [[ "$Version" == "" ]]; then
        FATAL "No version was specified. Please, use -v to set mandatory version parameter"
    fi
    # Check on TL
    if [[ "$TLName" == "" ]]; then
        FATAL "No TL was specified. Please, use -t to set mandatory TL parameter"
    fi
    TLConfigPath="$ConfigRoot/$TLName"
    if [ ! -d "$TLConfigPath" ]; then
        ERROR "TL config directory [$TLConfigPath] : not found !"
        INFO "Available TL in $ConfigRoot are :"
        list=$(cd $ConfigRoot;ls | grep $RootConfigName  2>&1)
        for file in $list;do
            INFO "  $file";
        done
        FATAL "Specify a correct TL"
    fi
    # Check on sequence file
    if $AllSeq;then  # if ALL, concate all seq files in ArgSeqFiles
       ArgSeqFiles=$(cd $ScriptPath/$SEQ_DIR_NAME;ls *.seq)
       ArgSeqFiles=$(echo $ArgSeqFiles | sed -e "s/ /,/g")
    fi
    if [[ "$ArgSeqFiles" == "" ]]; then
        FATAL "No Sequence file was specified. Please, use -s to set sequence file"
    fi
}

#----------------------------------------------------------------------------------------------------
# Function that a directory exists. If not, provide list of existing ones, and exit with fatal error
#----------------------------------------------------------------------------------------------------
function check_dir() {
    local __root=$1
    local __name=$2
    local __dir=$3
    local __fix=$4
    finalDir=$__root/$__dir
    if [ ! -d "$finalDir" ]; then
        INFO "Directory [$finalDir] was not found. Available(s) $__name are:"
        list=$(cd $__root;ls)
        for file in $list;do
            if [ -d "$__root/$file" ]; then INFO "  $file";  fi
        done
        FATAL "$__fix"
    fi
}

# ----------------------------------------------------------------------------------------------------
# Function that parse a sequence file and retrieve associated Test suites
#----------------------------------------------------------------------------------------------------
function parse_seq_file() {
    local __file=$1
    # Build full path for sequence file
    SeqRoot="$ScriptPath/$SEQ_DIR_NAME"
    SeqPath="$SeqRoot/$__file"
    show2  "Parsing sequence file" $SeqPath
    # Check existency
    if [ ! -f "$SeqPath" ]; then
        ERROR "Sequence file [$SeqPath] was not found !"
        INFO  "Available sequence in $SeqRoot are :"
        list=$(cd $SeqRoot;ls 2>&1)
        for file in $list;do
            INFO "  $file";
        done
        FATAL "Specify a correct Sequence file"

    fi
    # Parsing file
    local is_in_feat=false
    # Split line upon CR only
    IFS=$'\n'
    # put all lines in List
    List=$(cat ${SeqPath})
    # Loop on lines
    for line in ${List}; do
        # Ignore comments and spaces at end of string
        line=$(echo ${line} | sed -e "s/#.*//g" | sed -e 's/[[:space:]]*$//')
        if [[ "$line" == "" ]]; then
            continue
        fi
        #INFO "LINE=($line)"
        # Catch start of section
        if [[ "${line}" == "FEATURE="* ]]; then
            Feature=$(echo    $line | sed -e "s/FEATURE=//g")
            is_in_feat=true
            pathTS=$ProjectRoot/$TEST_SUITE_DIR_NAME/$Feature
            if [ ! -d "$pathTS" ];then
                FATAL "On feature $Feature:$pathTS not found"
            fi
        else
            # Line is either a simple robot filename or a robot+qc filenames suite
            # separator is ,
            robot=$(echo $line | cut -d ":" -f1)
            qcList=$(echo "$line," | cut -d ":" -f2)
            # Store current line as a test suite name
            if $is_in_feat; then
                add_TS  "$SeqPath"  "$Feature"  "$robot"  "$pathTS/$robot" "$qcList"
            fi
        fi
    done
}


function add_TS() {
    local __seq=$1
    local __feat=$2
    local __name=$3
    local __loc=$4
    local __qc=$5
    let NbTS=NbTS+1
    TestSuite[$NbTS,$SEQ]="$__seq"
    TestSuite[$NbTS,$FEAT]="$__feat"
    TestSuite[$NbTS,$NAME]="$__name"
    TestSuite[$NbTS,$LOC]="$__loc"
    TestSuite[$NbTS,$QC]="$__qc"
    #INFO "SEQ=(${TestSuite[$NbTS,$SEQ]}) FEAT=(${TestSuite[$NbTS,$FEAT]}) NAME=(${TestSuite[$NbTS,$NAME]}) LOC=(${TestSuite[$NbTS,$LOC]})"
}

# ----------------------------------------------------------------------------------------------------
# Function that check a robot file and add it in list of test suites to execute
#----------------------------------------------------------------------------------------------------
function parse_robot_file() {
    local __file=$1
    # Here, we are expecting a full path to robot, relative from testsuite.
    # Should be composed of <FeaturePath>/<RobotFileName>
    pathTS="$ProjectRoot/$TEST_SUITE_DIR_NAME"
    if [ ! -f "$pathTS/$__file" ]; then
        FATAL   "Robot file [$pathTS/$__file] not found !"
    fi
    featPath=$(dirname $__file)
    name=$(basename $__file)
    # Adding a new TS
    add_TS "TS" "$featPath" "$name" "$pathTS/$__file" ""
}

#----------------------------------------------------------------------------------------------------
# Function that extract list of sequence file, then parse them
#----------------------------------------------------------------------------------------------------
function get_seq_files() {
    IFS=',' read -r -a array <<< "$ArgSeqFiles"
    NbSeqFile="${#array[@]}"
    for file in "${array[@]}"; do
        if [[ "$file" == *".robot" ]];   then parse_robot_file $file;
        else                                  parse_seq_file $file;   fi
    done
    NbErr=0
    for ((i=1;i<=NbTS;i++)) do
        if [ ! -f "${TestSuite[$i,$LOC]}" ]; then
            file=$(basename ${TestSuite[$i,$SEQ]})
            ERROR "$file:Feature ${TestSuite[$i,$FEAT]}:Test suite [${TestSuite[$i,$NAME]}]:${TestSuite[$i,$LOC]} not found"
            let NbErr=NbErr+1
        fi
        if [ -z "${TestSuite[$i,$QC]}" ]; then continue; fi
        dir=$(dirname "${TestSuite[$i,$LOC]}")
        # QC may be a list of qc files
        IFS=',' read -r -a qcArray <<< "${TestSuite[$i,$QC]}"
        for qcFile in ${qcArray[@]}; do
            file="$dir/${qcFile}"
            if [ ! -f "$file" ]; then
                ERROR "QC file $file not found"
                let NbErr=NbErr+1
            fi
        done
    done
    if [ $NbErr -gt 0 ]; then
        FATAL "$NbErr errors met while parsing sequence files"
    fi
}

#----------------------------------------------------------------------------------------------------
# Function that set mode of execution
#----------------------------------------------------------------------------------------------------
function set_exec_mode() {
    if $DryMode;then
        RunModeStr="${BG_GREEN}${BLACK}DRY Run${NORMAL}"
        ModeDir="Dry"
        DryModeCmd=" --dryrun"
    else
        RunModeStr="${BG_RED}${BLACK}REAL Run on Target${NORMAL}"
        ModeDir="Real"
        DryModeCmd=""
    fi
}

#----------------------------------------------------------------------------------------------------
# Function that check path to robot command
#----------------------------------------------------------------------------------------------------
function get_robot_path() {
    res=$(which robot 2>&1)
    if [[ "$res" == "which: no robot in"* ]];then
        res=$(echo $res | cut -d "(" -f2 | cut -d ")" -f1 )
        FATAL "Unable to find path to robot in :$res"
    fi
    RobotPath=$res
}

#----------------------------------------------------------------------------------------------------
# Function that build list of arguments to add to robot command upon a list of tags
#----------------------------------------------------------------------------------------------------
function getTagOption() {
    local __option=$1
    local __list=$2
    OptionCmd=""
    IFS=',' read -r -a array <<< "$__list"
    for tag in "${array[@]}"; do
        OptionCmd="$OptionCmd -$__option $tag"
    done
    echo $OptionCmd
}

#----------------------------------------------------------------------------------------------------
# Function that build result path and root robot command
#----------------------------------------------------------------------------------------------------
function prepare_robot() {
    get_robot_path
    ResRootPath="$ResRootRootPath/$Version/$TLName/$ModeDir/$TimeStamp"
    if [ -z "$LuasharkVersion" ]; then LuasharkVersion=$Version; fi
    AfPath="$WftRootUrl/$LuasharkVersion/$Qcow2Nameprefix-$LuasharkVersion.qcow2"
    RobotRootCmd="$RobotPath $DryModeCmd -V $TLConfigPath -v version:$Version $OtherOption -v AF_PATH:$AfPath $DebugOption"
    # Preparing options for tag exclusion/inclusion
    IncludeTagOption=$(getTagOption "i" "$IncludeTagList")
    ExcludeTagOption=$(getTagOption "e" "$ExcludeTagList")
    INFO "IncludeTagOption=[$IncludeTagOption]"
    RobotRootCmd="$RobotRootCmd $IncludeTagOption $ExcludeTagOption"
}

#----------------------------------------------------------------------------------------------------
# Global display of all input and computed parameters
#----------------------------------------------------------------------------------------------------
function show_context() {
    INFO "GENERAL: -----------------------------------------------------------------------------------"
    show2 "Traces Dir NAME"      "$TracesDir"
    show2 "Project Root"         "$ProjectRoot"
    show2 "ROBOT Debug Option"   " $DebugOption"
    show2 "ROBOT Other Option"   " $OtherOption"
    show2 "Version of load "     "$Version"
    show2 "Version of Luashark"  "$LuasharkVersion"
    show2 "AF PATH"              "$AfPath"
    show2 "TL Config Path"       "$TLConfigPath"
    show2 "Sequence"             "$ArgSeqFiles"
    INFO "SEQUENCE: ----------------------------------------------------------------------------------"
    show2 "List of Include tags" "$IncludeTagList"
    show2 "List of Exclude tags" "$ExcludeTagList"
    show2 "Number of Execution"  "$NbExec"
    show2 "Mode"                 "$RunModeStr"
    show2 "Number of Test Suite" "$NbTS"
    for ((i=1;i<=NbTS;i++)) do
        if [ -z "${TestSuite[$i,$QC]}" ]; then qcStr=""; else qcStr="(QC:${TestSuite[$i,$QC]})"; fi
        str=$(printf "Feature:%-35s TS:%s $qcStr" "${TestSuite[$i,$FEAT]}" "${TestSuite[$i,$NAME]}" )
        show2 "   Test Suite $i" "$str"
    done
    INFO "COMMAND: ------------------------------------------------------------------------------------"
    show2 "Root path for results" "$ResRootPath"
    show2 "Path to robot"         "$RobotPath"
    show2 "ROBOT root Command"    "$RobotRootCmd"
    if $PauseMode;then pause; fi
}

#----------------------------------------------------------------------------------------------------
# Function that execute whole selected sequence with one robot command per robot file
#----------------------------------------------------------------------------------------------------
function exec_multi_robot() {
    ResPath="$ResRootPath"
    for ((nb=1;nb<=NbExec;nb++)) do
        if [ $NbExec -gt 1 ]; then
            ResPath="$ResRootPath.${nb}_of_${NbExec}"
        fi
        for ((i=1;i<=NbTS;i++)) do
            # Remove .seq from sequence file and .robot from test suite file
            SeqShort=$(basename ${TestSuite[$i,$SEQ]} | sed -e "s/\.seq//g")
            TSNameShort=$(echo ${TestSuite[$i,$NAME]} | sed -e "s/\.robot//g")
            # Compute Result path and robt command
            LoopTimeStamp=$(date +"%Y%m%d_%H%M%S")
            ResFinalPath="$ResPath/$LoopTimeStamp.$SeqShort.$TSNameShort"
            RobotCmd="$RobotRootCmd -N \"$TSNameShort\" -d \"$ResFinalPath\" \"${TestSuite[$i,$LOC]}\""
            ResFile="$ResFinalPath/$RES_FILE_NAME"
            exec_robot_cmd $nb $i
            # Display diagnosis
            print_diag $__loop  $__i
            if $PauseMode;then pause; fi
        done
        # Remainder of diagnosis for loop
        INFO " "
        big_bar "DIAGNOSIS for Loop $nb/$NbExec"
        for ((i=1;i<=NbTS;i++)) do
            prefix=$(printf "  %-80s" "${TestSuite[$i,$NAME]}")
            if ${TestSuite[$i,$DIAG]};then
                high_line "$prefix:PASS"    "${BG_GREEN}${BLACK}"
            else
                high_line "$prefix:FAILED"  "${BG_RED}${BLACK}"
            fi
        done
    done
}

#----------------------------------------------------------------------------------------------------
# Function that executes one robot command
#----------------------------------------------------------------------------------------------------
function exec_robot_cmd() {
    local __loop=$1
    local __i=$2
    if ! $CiMode;then
        big_bar " LOOP: $__loop/$NbExec  Test Suite:$__i/$NbTS  Sequence:$SeqShort  Name:${TestSuite[$i,$NAME]}"
    fi
    show2 "Res Path"        "$ResFinalPath"
    show2 "ROBOT Command"   "$RobotCmd"
    high_line $(printf '_%.0s' {1..128})   ""
    # Create path for results
    mkdir -p "$ResFinalPath"
    NewTraceFile="$ResFinalPath/$TRACE_FILE_NAME"
    touch "$NewTraceFile"
    # Put first part of traces in global log file
    cat  $TraceFile >> "$NewTraceFile"
    rm $TraceFile

    # Launch robot cmmand and append next trace in contextual result file
    ExportCmd="export ftp_proxy= && export http_proxy= && export https_proxy= && export HTTP_PROXY= && export HTTPS_PROXY= && export | grep -i proxy"
    eval "$ExportCmd && $RobotCmd 2>&1 | tee -a \"$NewTraceFile\""
}

function print_diag() {
    local __loop=$1
    local __i=$2
    diag=false
    prefix="LOOP: $__loop/$NbExec  Test Suite:$__i/$NbTS  Sequence:$SeqShort  Name:${TestSuite[$i,$NAME]} DIAG"
    res=$(grep "tests total" $NewTraceFile | grep passed | grep failed)
    if [[ "$res" == *", 0 failed"* ]]; then
        TestSuite[$i,$DIAG]=true
        high_line "$prefix:PASS"   "${BG_GREEN}${BLACK}"
    else
        TestSuite[$i,$DIAG]=false
        high_line "$prefix:FAILED"   "${BG_RED}${BLACK}"
    fi
    INFO ""
}


#----------------------------------------------------------------------------------------------------
# Function that compute more pertinent suite name upon context
#----------------------------------------------------------------------------------------------------
function build_suite_name() {
    if [ "$NbSeqFile" == "1" ]; then
        # SuiteName=$(echo $ArgSeqFiles | sed -e "s/\.seq//g" | sed -e "s/ /_/g")
        if [[ "$ArgSeqFiles" == *".robot" ]]; then
            SuiteName='"${TestSuite[1,$NAME]%.*}"'
        else
            SuiteName=${ArgSeqFiles%.*}
        fi
    else
        SuiteName="MultiSeq"
    fi
}

#----------------------------------------------------------------------------------------------------
# Function that execute whole selected sequence with one robot command (Ci mode = true)
#----------------------------------------------------------------------------------------------------
function exec_unique_robot() {
    ResFinalPath="$ResRootPath"
    ListTS=""
    for ((nb=1;nb<=NbExec;nb++)) do
        # Build list of TS paths for unique robot command
        for ((i=1;i<=NbTS;i++)) do
            ListTS="$ListTS  \"${TestSuite[$i,$LOC]}\""
        done
    done
    # Build Suite name
    build_suite_name

    RobotCmd="$RobotRootCmd -d \"$ResFinalPath\" -N \"$SuiteName\" $ListTS"
    exec_robot_cmd
}

#----------------------------------------------------------------------------------------------------
# Function that execute whole selected sequence (all cases)
#----------------------------------------------------------------------------------------------------
function exec_robot_sequence() {
    INFO "EXECUTION: ----------------------------------------------------------------------------------"
    if $CiMode; then
        exec_unique_robot
    else
        exec_multi_robot
    fi
}

#----------------------------------------------------------------------------------------------------
# Function that split a unique debug.log into n separate TSdebug.<TS>.log (case of Ci mode)
#----------------------------------------------------------------------------------------------------
function split_debug_log_if_required() {
    if $CiMode; then
        # Defining file to split and target dir for partial logs
        DebugFile=$ResRootPath/debug.log
        PartialLogDir="TSLog"
        mkdir -p $ResRootPath/$PartialLogDir
        INFO "Splitting debug file : $DebugFile"
        # Build pattern for start TS and initialize internal counters
        Name=$(echo $SuiteName | sed -e "s/_/ /g")
        StartPattern=" - INFO - +- START SUITE: $Name."
        CurLoop=1
        CurTSIndex=0
        # Loop on lines in debug.log
        for line in $(cat ${DebugFile}); do
            if [[ "$line" == *"$StartPattern"* ]]; then
                # Update TS index
                let CurTSIndex=CurTSIndex+1
                # Update counters upon loop
                if (( $CurTSIndex > $NbTS ));then
                    let CurLoop=CurLoop+1
                    let CurTSIndex=1
                fi
                # Start extract TS name : Removing 21 first character + startPattern
                # 21 is for : "YYYYMMDD HH:MM:SS.nnn" (ex:"20191031 10:53:52.843)
                lenPrefix=$(echo $((21+${#StartPattern})))
                CurTS=$(echo ${line:$lenPrefix})
                # Then, removing trailer ( [ ]) and replace " " with "_"
                CurTS=$(echo $CurTS | sed -e "s/ \[ \]//g" | sed -e "s/ /_/g")
                # Adding index if required
                if (( $NbExec > 1 )); then CurTS="${CurTS}.LOOP_$CurLoop"; fi
                # Compute name of partial log file
                PartialDebugLog="$ResRootPath/$PartialLogDir/TSdebug.$CurTS.log"
                INFO "  LOOP=$CurLoop TS=$CurTSIndex FILE=$PartialDebugLog"
            fi
            # Flush line in pertinent file
            if (( CurTSIndex > 0 )); then echo "$line" >> $PartialDebugLog; fi

        done
    fi
}

#----------------------------------------------------------------------------------------------------
# Function that split a unique output.xml into n separate TSOutput.<TS>xml (case of Ci mode)
#----------------------------------------------------------------------------------------------------
function split_output_xml_if_required() {
    if $CiMode; then
        # Defining file to split and target dir for partial logs
        OutputFile=$ResRootPath/output.xml
        PartialLogDir="TSLog"
        mkdir -p $ResRootPath/$PartialLogDir
        INFO "Splitting output xml file : $OutputFile"
        # Build pattern for start TS and initialize internal counters
        Name=$(echo $SuiteName | sed -e "s/_/ /g")
        CurLoop=1
        CurTSIndex=0
        Header=""
        Trailer="</robot>\n"
        InHeader=true
        InSuite=false
        # Loop on lines in debug.log
        for line in $(cat ${OutputFile}); do
            if [[ "$line" == *"<suite id="* ]]; then InHeader=false;          fi
            if [[ "$line" == *"<suite source="* ]]; then
                InSuite=true
                InHeader=false
                # Update TS index
                let CurTSIndex=CurTSIndex+1
                # Update counters upon loop
                if (( $CurTSIndex > $NbTS ));then
                    let CurLoop=CurLoop+1
                    let CurTSIndex=1
                fi
                # Get Path to test suite
                CurTS=$(echo $line | cut -d "\"" -f 2)
                CurTS=$(basename $CurTS)
                CurTS=$(echo $CurTS | sed -e "s/ \[ \]//g" | sed -e "s/ /_/g")
                # Adding index if required
                if (( $NbExec > 1 )); then CurTS="${CurTS}.LOOP_$CurLoop"; fi
                # Compute name of partial log file
                PartialOutputXml="$ResRootPath/$PartialLogDir/TSoutput.$CurTS.xml"
                INFO "  LOOP=$CurLoop TS=$CurTSIndex FILE=$PartialOutputXml"
                echo -e "$Header" > $PartialOutputXml
            fi
            if [[ "$line" == *"</suite>"* ]]; then
                if $InSuite;then
                    echo -e "$line" >> $PartialOutputXml
                    echo -e "$Trailer" >> $PartialOutputXml
                fi
                InSuite=false
            fi
            if $InHeader; then Header="$Header$line\n"; fi
            # Flush line in pertinent file
            if $InSuite; then echo "$line" >> $PartialOutputXml; fi
        done
    fi
}
#----------------------------------------------------------------------------------------------------
# Compute gNB branch depending on gNB load =>  compute variables : Branch 
#----------------------------------------------------------------------------------------------------
function check_branch() {
  # compute $Branch
  prefixClassical5G19_B1_1="7"
  prefixClassical5G19_B1_2="1836"
  prefixClassical5G19_B2_1="7"
  prefixClassical5G19_B2_2="2836"  
  prefixCloud5G19_B1_1="7"
  prefixCloud5G19_B1_2="2106"
  prefixCloud5G19_B2_1="7"
  prefixCloud5G19_B2_2="3106" 
  # 20A
  prefixClassical5G20A_B1_1="9"
  prefixClassical5G20A_B1_2="1800"

  ver=$1
  d1=$(echo $ver | cut -d '.' -f 1)
  d2=$(echo $ver | cut -d '.' -f 2)
  d3=$(echo $ver | cut -d '.' -f 3)

  echo "debug_xxx_d1=$d1"
  echo "debug_xxx_d2=$d2"
  echo "debug_xxx_d3=$d3"

  Branch="Trunk"
  if [ "$d1" == "$prefixClassical5G19_B1_1" ] && [ "$d2" == "$prefixClassical5G19_B1_2" ] ; then
    Branch="5G19B_Branch"
  elif [ "$d1" == "$prefixClassical5G19_B2_1" ] && [ "$d2" == "$prefixClassical5G19_B2_2" ] ; then
    Branch="5G19B_Branch" 
  elif [ "$d1" == "$prefixClassical5G20A_B1_1" ] && [ "$d2" == "$prefixClassical5G20A_B1_2" ] ; then
    Branch="5G20A_Branch"    
  elif [ "$d1" == "$prefixCloud5G19_B1_1" ] && [ "$d2" == "$prefixCloud5G19_B1_2" ] ; then
    Branch="5G19B_Branch"     
  elif [ "$d1" == "$prefixCloud5G19_B2_1" ] && [ "$d2" == "$prefixCloud5G19_B2_2" ] ; then
    Branch="5G19B_Branch"        
  else
    echo "Branch not found. Trunk by default"
    #ERROR "Branch not found for gNB load $ver"
  fi
}

#----------------------------------------------------------------------------------------------------
# # Compute QC path in .qc depending on Branch  =>  compute variables : targetFile 
#----------------------------------------------------------------------------------------------------
function custo_qcFile() {
  idir=$1
  iFile=$2
  iBranch=$3
  cp $idir/$iFile /tmp/$iFile
  echo "Before custo "
  more /tmp/$iFile
  if [[ $iBranch == "5G19B_Branch" ]] ; then
    sed -i 's/Trunk/5G19B\\\\Regression/g' /tmp/$iFile
    targetFile=/tmp/$iFile
  elif [[ $iBranch == "5G20A_Branch" ]] ; then
    sed -i 's/Trunk/5G20A\\\\Regression/g' /tmp/$iFile
    targetFile=/tmp/$iFile
  elif [[ $iBranch == "Trunk" ]] ; then
    echo "No custo for Trunk"
    targetFile=/tmp/$iFile
  else
    FATAL "Branch not found to custo .qc file for gNB load $Version. QC could not be updated"
  fi
}

#----------------------------------------------------------------------------------------------------
# Function that update QC if required
#----------------------------------------------------------------------------------------------------
function update_QC_if_required() {
    if $QcOption;then
        INFO "Updating QC"
        for ((i=1;i<=NbTS;i++)) do
            if [ ! -z "${TestSuite[$i,$QC]}" ]; then
                dir=$(dirname ${TestSuite[$i,$LOC]})
                IFS=',' read -r -a qcArray <<< "${TestSuite[$i,$QC]}"
                for qcFile in ${qcArray[@]}; do
                    INFO "dir=$dir"
                    INFO "qcFile=${qcFile}"
                    PartialLogDir="TSLog"
                    xmlFile="$ResRootPath/$PartialLogDir/TSoutput.${TestSuite[$i,$NAME]}.xml"
                    #qcFile=$dir/${qcFile}
                    qcFileToUse=$dir/${qcFile}

                    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                    # compute Branch and set result in $Branch
                    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                    if $QcBranch;then
                        check_branch $Version
                        # FOR_DEBUG
                        # echo "Compute Branch=$Branch"
                        if [[ "$Branch" == "Branch not found" ]]; then
                            # QC could not be updated !!
                            FATAL "Branch not found for gNB load $Version. QC could not be updated"
                        else
                            # compute qc path depending on $Branch and set result on $targetFile
                            custo_qcFile $dir ${qcFile} $Branch
                            # INFO "targetFile=${targetFile}"
                            qcFileToUse=$targetFile
                            # FOR_DEBUG
                            echo "Compute and more targetFile=$targetFile"
                            more $targetFile
                            $qcFileToUse=$targetFile
                            # add new mandatory option -l (LABEL) 
                            INFO "  update QC command with: send -ro $xmlFile -qc $qcFileToUse -l $TLName -tl $TLName --sw_version 5G_$Version:base -nc"
                            ute_reporting_portal send -ro $xmlFile -qc $qcFileToUse -l $TLName -tl $TLName --sw_version 5G_$Version:base -nc
                        fi
                    else
                        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                        # without compute branch
                        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                        # add new mandatory option -l (LABEL)
                        INFO "  update QC command with: send -ro $xmlFile -qc $qcFileToUse -l $TLName -tl $TLName --sw_version 5G_$Version:base -nc"
                        ute_reporting_portal send -ro $xmlFile -qc $qcFileToUse -l $TLName -tl $TLName --sw_version 5G_$Version:base -nc
                    fi


                done
            fi
        done
    fi
}

#----------------------------------------------------------------------------------------------------
# Function that clean oldest files in /ebs/<user>CI/...
#----------------------------------------------------------------------------------------------------
function cleanup_oldest_files() {
    # Listing oldest files
    cmd="find $ResRootRootPath -type f -mtime +$NbDay"
    res=$(eval $cmd)
    INFO "Listing Files older than $NbDay days:CMD=$cmd"
    INFO "RES=$res"
    # Removing oldest files
    cmd="$cmd -exec rm -f {} \;"
    INFO "Removing Files older than $NbDay days:CMD=$cmd"
    res=$(eval $cmd)
    INFO "RES=$res"
}

#----------------------------------------------------------------------------------------------------
# MAIN
#----------------------------------------------------------------------------------------------------
initLog
analyze_arguments $@
check_mandatory_arguments
get_seq_files
set_exec_mode
prepare_robot
show_context
exec_robot_sequence
split_debug_log_if_required
split_output_xml_if_required
update_QC_if_required
cleanup_oldest_files
#!/bin/bash
#··author·Bartosz·Grzegorczyk
#··contact·bartosz.grzegorczyk@nokia.com
#··team·MN·RAN·L3·SW·1·WRO·7·SG
#··e.g··run·script·like:
#··bash /home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/scripts/run_and_report_tests.sh -p
#··bash /home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/scripts/run_and_report_tests.sh -f /path_to_test_file
#··testrunner -p
#··testrunner -f /path_to_test_file

#@Description  This script is used to automatically run suite of tests. User can choose multiple test cases, run and upload them to rotta.
#              After runs tests can be reported automatically to reporting portal.
#              After every test run gnb would be reset to basic scf if there is no "Send Full Commissioning" in test case body.
#              User have to provide file with test cases absolute paths and choose whether tests have to be reported with True/False flag.
#              User can also choose if he want to upload test logs to rotta \5G_3\wroclaw\ET_L3 folder with Upload/NoUpload flag.

source /home/ute/test_repo/bin/activate;

path_to_tests="/home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/"

#Text decoration
declare -rA color_text=(
       [bold-red]='\033[1;38;5;210m'
     [bold-green]="\033[1;38;5;42m"
      [bold-cyan]='\033[1;38;5;63m'
     [bold-white]='\033[1;38;5;255m'
)

declare -r color_reset='\e[0m'

function text_green() {
local decoration=$(decorate_text $@)
echo -e "${color_text[bold-green]}" "$decoration" "${color_reset}"
}

function text_red() {
local decoration=$(decorate_text $@)
echo -e "${color_text[bold-red]}" "$decoration" "${color_reset}"
}

function text_white() {
local decoration=$(decorate_text $@)
echo -e "${color_text[bold-white]}" "$decoration" "${color_reset}"
}

function text_blue() {
local decoration=$(decorate_text $@)
echo -e "${color_text[bold-cyan]}" "$decoration" "${color_reset}"
}

function decorate_text {
local text="$@"
# Header length have to be round number
local header_length=180

local textsize=$(expr length "$text")
if [ $((textsize % 2)) -ne 0 ]; then
    text="$text "
    textsize=$((textsize + 1))
fi

# Generate hashes for text and header footer strings
if [ $(($header_length-$textsize-3)) -gt 0 ]; then
    local hashsize="#"$(printf '%*s' $(( ( $header_length-$textsize-3)/2 )) '' | tr ' ' '#');
else
    local hashsize="";
fi
local header=$(printf '%*s' "$header_length" '' | tr ' ' '#')
local footer=$(printf '%*s' "$header_length" '' | tr ' ' '#')

# Add header and footer and hash to the text
printf "\n$header\n"
printf "%s\n" "$hashsize $text $hashsize"
printf "$footer\n"
}

function check_and_save_host_name() {
name_of_host=${HOSTNAME//-/_}
text_blue "Name of host is $name_of_host"
}

function get_users_testline_topology() {
topology=$(grep "SetExecutionParams ran" /home/ute/results/logs/DEBUG_log.txt | awk -F , '{print $4}' | awk '{print $2}' | sed "s/'//g")
text_blue "Your testline topology is "$topology
}

# Find software version and check if software is correct with Regex
function get_software_version() {
software_version=$(ssh -q toor4nsn@192.168.255.129 \
"cat /rom/TargetBD_SBT* | grep -oG 'swReleaseVersionPackageName=\"SBTS[0-9]\{2\}[R]*[0-9]*_ENB_[0-9]\{4\}_[0-9]\{6\}_[0-9]\{6\}' \
| grep -oG 'SBTS[0-9]\{2\}[R]*[0-9]*_ENB_[0-9]\{4\}_[0-9]\{6\}_[0-9]\{6\}'")
text_blue "Your software version is "$software_version
}

# This function checks if argument in file is test case path, information if user wants to upload tests to rotta (Upload/NoUpload),
# report tests(True/False) or user provide test tag (CIT/CRT).
function get_user_arguments() {
tests_to_execute=()
for test_case in $@; do
    if [[ -f $test_case && "$test_case" == *".txt" ]]; then
        declare -a arr
        text_white "Loading tests from file: "$test_case
        log_to_python "Loading tests from file: " $test_case
        while read -r line; do
            arr+=$line" "
        done <$test_case
        for test_in_file in $arr; do
            if [[ $test_in_file = "True" || $test_in_file = "False" ]]; then
                set_report_tests_flag $test_in_file
            elif [[ $test_in_file = "Upload"* || $test_in_file = "NoUpload" ]]; then
                set_upload_to_rotta_flag $test_in_file
            elif [[ $test_in_file = "CIT" || $test_in_file = "CRT" ]]; then
                test_tag=$test_in_file
            elif [[ -f "$test_in_file" ]]; then
                text_white "You added test "$test_in_file
                log_to_python "New test added: " $test_in_file
                tests_to_execute+=($test_in_file)
            else
                text_red "Invalid test. Check your test path for "$test_in_file
            fi
        done
    else
        text_red "Invalid testpath. Check your test path for "$test_case
    fi
done
text_green "List of tests that will be executed: "${tests_to_execute[@]/$path_to_tests}
}

# Function set report_tests variable to "True" or "False" value
function set_report_tests_flag() {
true_or_false=$1
if [[ $true_or_false = "True" || $true_or_false = "False" ]]; then
    report_tests=$true_or_false
    text_blue "Tests will be reported after runs: "$report_tests
    log_to_python "Tests will be reported after runs: " $report_tests
else
    text_red "Invalid input..."
fi
}

# Function set rotta_upload variable to "Upload" or "NoUpload" value
function set_upload_to_rotta_flag() {
upload_or_not=$1
if [[ $upload_or_not = "Upload"* || $upload_or_not = "NoUpload" ]]; then
    rotta_upload=$(echo $upload_or_not | awk -F "_" '{print $1}' )
    rotta_path=$(echo $upload_or_not | awk -F "_" '{sub($1"_", ""); print}' )
    if [[ "${rotta_path: -1}" != "/" ]]; then
      rotta_path="${rotta_path}/"
    fi
    text_blue "Tests will be uploaded after runs: "$rotta_upload
    text_blue "Tests will be uploaded to: "$rotta_path
    log_to_python "Tests will be uploaded after runs: " $rotta_upload
    log_to_python "Tests will be uploaded to: " $rotta_path
else
    text_red "Invalid input..."
fi
}

#Log functions depends on lists created in run_tests_and_report_them function
function log_run_result() {
if [ ${#successfull_tests[@]} -eq 0 ]; then
    text_blue "Successfully run tests: -"
else
    printf '%s\n' "$(text_blue "Successfully run tests: ${successfull_tests[*]}")"
fi
if [ ${#not_successfull_tests[@]} -eq 0 ]; then
    text_blue "Not successfully run tests: -"
else
    printf '%s\n' "$(text_blue "Not successfully run tests: ${not_successfull_tests[*]}")"
fi
}

function log_upload_result() {
if [ ${#uploaded_tests[@]} -eq 0 ]; then
    text_blue "Successfully uploaded tests: -"
else
    printf '%s\n' "$(text_blue "Successfully uploaded tests: ${uploaded_tests[*]}")"
fi
if [ ${#not_uploaded_tests[@]} -eq 0 ]; then
    text_blue "Not uploaded tests: -"
else
    printf '%s\n' "$(text_blue "Not uploaded tests: ${not_uploaded_tests[*]}")"
fi
}

function log_report_result() {
if [ ${#reported_tests[@]} -eq 0 ]; then
    text_blue "Successfully reported tests: -"
else
    printf '%s\n' "$(text_blue "Successfully reported tests: ${reported_tests[*]}")"
fi
if [ ${#not_reported_tests[@]} -eq 0 ]; then
    text_blue "Not reported tests: -"
else
    printf '%s\n' "$(text_blue "Not reported tests: ${not_reported_tests[*]}")"
fi
}

# Run test, check if test was executed successfully and append list for successfull and not successfull reports. After running tests reset testline.
function run_tests_and_report_them() {
successfull_tests=()
not_successfull_tests=()
uploaded_tests=()
not_uploaded_tests=()
reported_tests=()
not_reported_tests=()
for test_case in "${tests_to_execute[@]}"; do
    text_green "Running test "$test_case
    log_to_python "Running test " $test_case
    echo
    current_time=$(date +"%d_%b_%Y_%I_%M_%p_")
    testpath=${test_case/$path_to_tests}
    test_name=$current_time$(echo "${testpath}" | awk -F '/' '{print $NF}')

    if [[ $test_tag == "CIT" || $test_tag == "CRT" ]]; then
        robot -V /home/ute/testline_configuration/$name_of_host -L TRACE -b debug.log -i $test_tag -d /home/ute/logs/$test_name $test_case
    else
        robot -V /home/ute/testline_configuration/$name_of_host -L TRACE -b debug.log -d /home/ute/logs/$test_name $test_case
    fi

    if [[ $? -eq "0" ]]; then
        successfull_tests+=($test_case)
        text_green "Test executed successfully"
        log_to_python "Test executed successfully " $test_case
        report_tests_and_check_if_tests_were_reported $test_name
    else
        not_successfull_tests+=($test_case)
        text_red "Test wasn't executed successfully"
        log_to_python "Test failed: " $test_case
    fi

    upload_tests_and_check_if_tests_were_uploaded $test_name $testpath

    text_white "Checking radio modules"
    log_to_python "Checking radio modules"
    echo
    robot -o NONE -l NONE -r NONE -t check_radio_modules /home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/scripts/script.robot

    if ! grep -oq "Send Full Commissioning" $test_case; then
        text_white "Trigerring testline reset"
        log_to_python "Trigerring testline reset"
        echo
        reset_testline_and_check_radios_are_up
    fi
    log_run_result
    log_upload_result
    log_report_result
done

#After function ends, triggger main and give user option to start another scripts
main
}

# Execute script for reseting testlines and check if reset was successfull
function reset_testline_and_check_radios_are_up() {
robot -o NONE -l NONE -r NONE -t reset_testline_and_wait_for_radio_modules /home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/scripts/script.robot
if [[ $? -eq "0" ]]; then
    text_green "TESTLINE RESET - EXECUTED SUCCESSFULLY"
    log_to_python "Testline reset - Executed successfully"
else
    log_run_result
    text_red "TESTS WERE NOT REPORTED"
    text_red "PROBLEM WITH TESTLINE RESET - EXIT SCRIPT"
    log_to_python "Problem with testline reset - exit script"
    exit 1
fi
}

# Report test and check in report file if test was successfully reported. Delete directory before check.
function report_tests_and_check_if_tests_were_reported() {
text_white "Whether tests will be reported? " $report_tests
Test_run=$1
if [[ $report_tests == True ]]; then
    not_reported_tests+=($not_successfull_tests)
    text_white "Reporting tests"
    log_to_python "Reporting tests"
    rm -r /home/ute/reporting_portal_report &>/dev/null
    echo
    ute_reporting_portal send -ro /home/ute/logs/${Test_run/$path_to_tests}/output.xml -tl $name_of_host --sw_version $software_version --info $topology -l $topology
    cat /home/ute/reporting_portal_report/collected/reporting_portal.json | grep -q "RAN_ET"
    if [[ $? -eq "0" ]]; then
        reported_tests+=($Test_run)
        text_green "Test reported successfully"
        log_to_python "Test reported successfully " $Test_run
    else
        not_reported_tests+=($Test_run)
        text_red "There was problem with reporting test!"
        log_to_python "There was problem with reporting test! " $Test_run
    fi
else
    log_run_result
fi
log_run_result
}

# Upload test and check if test was successfully uploaded.
function upload_tests_and_check_if_tests_were_uploaded() {
test_to_upload=$1
test_case_name=$2
text_blue "Whether tests will be uploaded? " $rotta_upload
if [[ $rotta_upload == "Upload" ]]; then
    sudo cp -r /home/ute/logs/$test_to_upload/. $rotta_path$test_to_upload
    if [[ $? -eq "0" ]]; then
        text_green "Test uploaded successfully to "$rotta_path$test_to_upload
        log_to_python "Test uploaded successfully to " $rotta_path$test_to_upload
        uploaded_tests+=($test_to_upload)
    else
        text_red "There was problem with uploading test to rotta!"
        log_to_python "There was problem with uploading test to rotta!"
        not_uploaded_tests+=($test_to_upload)
    fi
    log_upload_result
fi
log_run_result
}

# Run python scripts
function run_python_script() {
file="/tmp/testrunner_tmp_file"

if ! kill -0 $PID_python 2>/dev/null ; then
    python3 /home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/scripts/test_picker_gui.py &
fi

PID_python=$(pgrep -o -f "python3 /home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/scripts/test_picker_gui.py")
trap handle_sigint SIGINT

while true; do
    state=$(cat $file)
    if [[ "$state" == "Start_test" ]]; then
        echo > $file
        sleep 2
        log_to_python "Starting test runs"
        break
    elif [[ "$state" == "Clear_scf" ]]; then
        echo > $file
        sleep 2
        log_to_python "Starting testline full commissioning"
        run_testline_commissioning
        log_to_python "End_of_stream"
    elif [[ "$state" == "Reset_testline" ]]; then
        echo > $file
        sleep 2
        log_to_python "Starting testline reset"
        run_reset_testline
        log_to_python "End_of_stream"
    elif [[ "$state" == "Check_radios" ]]; then
        echo > $file
        sleep 2
        log_to_python "Starting radios check"
        run_check_radios
        log_to_python "End_of_stream"
    elif [[ "$state" == "Open_admin" ]]; then
        echo > $file
        sleep 2
        log_to_python "Starting admin panel"
        run_admin
        log_to_python "End_of_stream"
    elif [[ "$state" == "Setup_pycharm" ]]; then
        echo > $file
        sleep 2
        log_to_python "Starting pycharm"
        run_setup_pycharm
        log_to_python "End_of_stream"
    elif [[ "$state" == "Report"* ]]; then
        read report variable <<< "$state"
        Old_IFS=$IFS
        IFS=' ' read -ra lista <<< "$variable"
        IFS=$Old_IFS
        echo > $file
        sleep 2
        log_to_python "Start test reporting"
        run_report_tests "${lista[@]}"
        log_to_python "End_of_stream"
    elif [[ "$state" == Delta* ]]; then
        delta_path=$(echo $state | cut -d' ' -f2)
        echo > $file
        sleep 2
        log_to_python "Starting delta commissioning"
        run_activate_delta $delta_path
        log_to_python "End_of_stream"
    elif [[ "$state" == "End_bash" ]]; then
        echo > $file
        exit 0
    fi
done
}

function run_admin() {
python3 /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/scripts/open_admin.py
if [ $? -eq 0 ]; then
  log_to_python "Admin started successfully"
else
  log_to_python "There was problem with starting admin"
fi
}

function run_setup_pycharm() {
bash /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/scripts/setup_pycharm.sh
if [ $? -eq 0 ]; then
  log_to_python "Pycharm started successfully"
else
  log_to_python "There was problem with starting pycharm"
fi
}

function run_check_radios() {
robot -o NONE -l NONE -r NONE -t check_radio_modules /home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/scripts/script.robot
if [ $? -eq 0 ]; then
  log_to_python "Radios check successful - all radios are up!"
else
  log_to_python "Radios check failed"
fi
}

function run_testline_commissioning() {
robot -o NONE -l NONE -r NONE -t reset_testline_and_wait_for_radio_modules /home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/scripts/script.robot
if [ $? -eq 0 ]; then
  log_to_python "Testline commissioning was successful - all radios are up!"
else
  log_to_python "Testline commissioning failed"
fi
}

function run_reset_testline(){
robot -o NONE -l NONE -r NONE -t reset_site /home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/scripts/script.robot
if [ $? -eq 0 ]; then
  log_to_python "Testline reset was successful - all radios are up!"
else
  log_to_python "Testline reset failed"
fi
}

function run_activate_delta() {
robot --variable DELTA_PATH:$1 -t load_delta /home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/scripts/script.robot
if [ $? -eq 0 ]; then
  log_to_python "Delta loaded successfully"
else
  log_to_python "There was problem with loading delta"
fi
}

function run_report_tests() {
local zmienna=("$@")
for Test_run in "${zmienna[@]}"; do
    ute_reporting_portal send -ro $Test_run -tl $name_of_host --sw_version $software_version --info $topology -l $topology
    cat /home/ute/reporting_portal_report/collected/reporting_portal.json | grep -q "RAN_ET"
    if [ $? -eq "0" ]; then
        text_green "Test reported successfully"
        log_to_python "Test reported successfully " $Test_run
    else
        text_red "There was problem with reporting test!"
        log_to_python "There was problem with reporting test! " $Test_run
    fi
done
}

function run_rotta_script() {
if ! [ -d "/home/ute/rotta/5G_3/wroclaw/ET_L3" ]; then
    while true; do
        text_white "Rotta folder have to be installed. Enter your credentials."
        sudo bash /home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/scripts/mount_rotta.sh
        if [ -d "/home/ute/rotta/5G_3/wroclaw/ET_L3" ]; then
          text_green "Rotta mounted successfully"
          break
        else
          text_red "There was problem  with mounting rotta. Check your username and password and try again!"
        fi
    done
fi
}

function save_scf() {
if ! [ -f "/home/ute/testline_init_results/configs/scfc.xml" ]; then
  text_white "Scf will be saved to /home/ute/testline_init_results/configs/scfc.xml"
  robot -o NONE -l NONE -r NONE -v DST_SCF_PATH:/home/ute/testline_init_results/configs/scfc.xml -t get_scf /home/ute/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/scripts/script.robot
fi
}

function find_latest_generated_file() {
# List the files in the directory and sort them by modification time
files=$(ls -t /home/ute/Desktop/)
# Get the latest file and store it in the variable "latest_file"
latest_file=$(echo "$files" | head -n 1)
echo "/home/ute/Desktop/$latest_file"
}

# Define usage function. Usage is printed when no arguments are provided to script
function usage {
echo "Usage: testrunner [-f <file>] [-p]"
echo "  -f <file>   Specify a file to use"
echo "  -p          Run Python script TestPicker"
exit 1
}

# Parse arguments
while getopts ":f:p" opt; do
  case ${opt} in
    f )
      file=$OPTARG
      ;;
    p )
      run_python=true
      ;;
    \? )
      echo "Invalid option: -$OPTARG" 1>&2
      usage
      ;;
    : )
      echo "Invalid option: -$OPTARG requires an argument" 1>&2
      usage
      ;;
  esac
done

# Check if no arguments were passed
if [ $OPTIND -eq 1 ]; then
    echo "No arguments supplied"
    usage
fi

cd /home/ute/
run_rotta_script
save_scf
check_and_save_host_name
get_users_testline_topology
get_software_version

function handle_sigint() {
kill -9 $PID_python
exit 1
}

function log_to_python() {
if [ "$#" -eq 1 ]; then
  (echo "$1" | nc localhost 12333) 2> /tmp/testrunner_errors
elif [ "$#" -eq 2 ];then
  (echo "$1 $2" | nc localhost 12333) 2> /tmp/testrunner_errors
fi
}

function main() {
# Run Python script if -p option was passed
if [ "$run_python" = true ]; then
    echo > /tmp/testrunner_tmp_file
    log_to_python "End_of_stream"
    run_python_script
    log_to_python "Name of host is " $name_of_host
    log_to_python "Your testline topology is " $topology
    log_to_python "Your software version is " $software_version
    file=$(find_latest_generated_file)
    text_white "Latest generated file is: $file"
    get_user_arguments $file
    run_tests_and_report_them
fi
}

main

# Use file if -f option was passed
if [[ -f $file && $file == *".txt" ]]; then
    # Your code using the file goes here
    get_user_arguments $file
    run_tests_and_report_them
fi

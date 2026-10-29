#!/bin/bash
echo CM_EXECUTION_LINK, $CM_EXECUTION_LINK
echo ENB_SW_VERSION, $ENB_SW_VERSION
ENB_SW_VERSION_SUITE_LOAD_TMP_FILE='/tmp/enb_sw_version.txt'
USERNAME=""
ls /home/ute/results/*/ > /dev/null 2>&1
if [ $? -ne 0 ]
then
    echo "No test suite results found. Please run test suite first"
    exit 1
fi

source /home/ute/test_repo/bin/activate

cd /home/ute/results/

dirs_found_str=$(ls -ltrd */ | awk '{print $9}' | sed 's#/$##' | grep -v 'reporting_portal_report')
dirs_found_arr=($dirs_found_str)
amount_of_dirs=$(echo $dirs_found_str | wc -w)

if [ $amount_of_dirs -gt 1 ]
then
    echo "Following test suites found:"
    for ((i = 1; i <= $amount_of_dirs; i++)); do
        echo "$i: ${dirs_found_arr[$i-1]}"
    done
    if [[ "$1" = "last" ]]
    then
        printf "Taking last results to report: ${dirs_found_arr[$amount_of_dirs-1]}"
        printf "\n"
        TEST_SUITE_NAME=${dirs_found_arr[$amount_of_dirs-1]}
    else
        printf "Choose test suite: "
        read -n 1 choosen_value
        printf "\n"
        TEST_SUITE_NAME=${dirs_found_arr[$choosen_value-1]}
    fi
else
    TEST_SUITE_NAME=${dirs_found_arr[0]}
fi

if ! [ -f /home/ute/results/$TEST_SUITE_NAME/output.xml ]
then
    echo "Test results file doesn't exists. Aborting"
    exit 1
fi

if  [ -f /home/ute/results/$TEST_SUITE_NAME/output_passed.xml ]
then
    echo "Test results with only passed tests found, reporting "
    OUTPUT_XML_NAME='output_passed.xml'
else
    echo "Using source filename output.xml "
    OUTPUT_XML_NAME='output.xml'
fi


TESTLINE=$(echo $HOSTNAME | sed "s/-/_/g" | sed 's/_[0-9]$//')
echo "Test Line: $TESTLINE"

if [ -n "$CM_EXECUTION_LINK" ]; then
  SUITE_LINK="--log_link http://logs.ute.nsn-rdnet.net/cloud/execution/$CM_EXECUTION_ID/execution_for_preparation_$CM_RESERVATION_ID/test_results/$TEST_SUITE_NAME/log.html"
	EXEC_LINK="--execution_link $CM_EXECUTION_LINK"
	echo EXEC_LINK FOUND, "$EXEC_LINK"
	echo SUITE_LINK FOUND, "$SUITE_LINK"
else
	EXEC_LINK=""
	SUITE_LINK=""
fi

UTE_TESTLINE_TYPE=$(/home/ute/MN/UTE/robotlte/resources/DevKr/testline_get_type.py | cut -f3)
echo "Test Line: $UTE_TESTLINE_TYPE"

if [ -n "$ENB_SW_VERSION" ]; then
  SW_VERSION=$ENB_SW_VERSION
  echo  "Getting sw version from environ"
else
  echo  "Getting sw version from enb_check_build.sh script"
  SW_VERSION=$(/home/ute/MN/UTE/robotlte/resources/DevKr/enb_check_build.sh | grep 'Active' | awk '{print $3}')
fi

if [ -z "$SW_VERSION" ]; then
  echo  "Getting sw version from suite load tmp file $ENB_SW_VERSION_SUITE_LOAD_TMP_FILE"
  SW_VERSION=$(cat $ENB_SW_VERSION_SUITE_LOAD_TMP_FILE)
fi

if [ -z "$SW_VERSION" ]; then
  echo  "Getting sw version from emssim"
  SW_VERSION=$(/home/ute/MN/UTE/robotlte/resources/DevKr/emssim_get_version.sh | grep 'Active' | awk '{print $7}')
fi

SOURCE_XML=/home/ute/results/$TEST_SUITE_NAME/$OUTPUT_XML_NAME

QC_FILE_PATH=$(dirname $(grep "suite" /home/ute/results/$TEST_SUITE_NAME/output.xml | grep source | awk -F 'source="' '{print $2}' | awk -F '"' '{print $1}'))/$TEST_SUITE_NAME.qc

if [ -f $QC_FILE_PATH ]
then
    QC_FILE=$(basename $QC_FILE_PATH)
    echo "QC File: $QC_FILE"
else
    echo "$TEST_SUITE_NAME.qc file not found. Aborting"
    exit 1
fi

if [ -n "$2" ]
then
    echo "USERNAME OPTION ADDED"
    USERNAME="--username $2"
fi

echo "ute_reporting_portal send -ro $SOURCE_XML -tl $TESTLINE --sw_version $SW_VERSION -qc $QC_FILE_PATH --info $UTE_TESTLINE_TYPE -l $UTE_TESTLINE_TYPE $EXEC_LINK $SUITE_LINK $USERNAME"
echo ""
ute_reporting_portal send -ro $SOURCE_XML -tl $TESTLINE --sw_version $SW_VERSION -qc $QC_FILE_PATH --info $UTE_TESTLINE_TYPE -l $UTE_TESTLINE_TYPE $EXEC_LINK $SUITE_LINK $USERNAME


*** Settings ***
Documentation    Suite description
...    Author:        qiang.1.zhou@nokia-sbell.com
...    Maintainer:    Zhou Qiang

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables    ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition
Test Timeout      73h
*** Variables ***
&{5880}=     peak_rate_config={"112":[60,20],"111":[216,9],"128":[110,20]}
...   HW_ID=Conf#12 Megafone:    site_mode=MULTI_RAT   ONAIR_TIME=10min

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${param1}     No X2 link available for a specific LTEENB
${param2}     No X2 link available
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}=    ${param1}    ${param2}
#@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}=   No X2 link available for a specific LTEENB
# ...                                  No X2 link available
#${TOP50}                             True
${GLO_SCOUT_TESTLINE_NAME}           1_5_UTE5G126

*** Test Cases ***

[3]Cell Block And Unblock All_with_resetBBMOD
    [Tags]    SBTS23R4:QC_626725    SBTS24R1:QC_693889    SBTS24R2:QC_775304
    ...    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=bbmodreset       config_id=5880
    [Timeout]     72h
    FOR    ${index}    IN RANGE    0    ${5}
        Log To Console     Site Reset times: ${index}+1
        Run Keyword And Ignore Error    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}
        Run Keyword And Ignore Error    Logging Multinode Start
        ${status}    ${return}    Run Keyword And Ignore Error
        ...    Common_SiSo_State Management_cell Lock_Then_resetBBMOD_Then_cell unlock
        ...    bbmod_id_list=EA184380689:EA200950182:DH212563609
        Run Keyword IF    '${status}'=='FAIL'
        ...    Logging Multinode Stop      ${TEST_LOGS_DIR_PATH}/FAIL_${index}     test_status=FAIL
        Run Keyword IF    '${status}'=='FAIL'    FAIL
    END
    [Teardown]  Testcase Basic Postcondition

[4]Ru lock And Unlock All_with_resetBBMO
    [Tags]    SBTS23R4:QC_626723    SBTS24R1:QC_764093    SBTS24R2:QC_826185
    ...    QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Cell Block And Unblock All_with_resetBBMOD    config_id=5880
	[Timeout]     72h
    FOR    ${index}    IN RANGE    0    ${5}
        Log To Console     Site Reset times: ${index}+1
        Run Keyword And Ignore Error    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}
        Run Keyword And Ignore Error    Logging Multinode Start
        ${status}    ${return}    Run Keyword And Ignore Error
        ...    Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
        ...       bbmod_id_list=EA184380689:EA200950182:DH212563609
        Run Keyword IF    '${status}'=='FAIL'
        ...    Logging Multinode Stop      ${TEST_LOGS_DIR_PATH}/FAIL_${index}     test_status=FAIL
        Run Keyword IF    '${status}'=='FAIL'    FAIL
    END
    [Teardown]  Testcase Basic Postcondition



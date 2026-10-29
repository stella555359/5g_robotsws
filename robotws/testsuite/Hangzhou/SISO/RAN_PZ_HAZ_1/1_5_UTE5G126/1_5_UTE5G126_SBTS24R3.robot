*** Settings ***
#Force Tags
Documentation    Suite description
...    Author:        qiang.1.zhou@nokia-sbell.com
...    Maintainer:    Zhou Qiang

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Variables    ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition
Test Timeout      73h
*** Variables ***
&{5880}=     peak_rate_config={"112":[60,20],"111":[216,9],"128":[110,20]}
...   HW_ID=Conf#12 Megafone:    site_mode=MULTI_RAT   ONAIR_TIME=10min

${YAFT}       YES
${INIT_SW_VERSION}        {'6478': 'SBTS23R4_ENB_0000_001194_000000'}
${TARGET_SW_VERSION}         {'6478': 'SBTS00_ENB_9999_230712_000013'}
${RB_TO_TARGET}     YES
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${param1}     No X2 link available for a specific LTEENB
${param2}     No X2 link available
${param3}     Unutilized hardware baseband resources by WCDMA
${param4}     Setup of X2 connectivity to gNB failed
${param5}     NgGnbInitFullReset
${param6}     OMU signaling connection failure in Abis interface
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}=    ${param1}   ${param2}    ${param3}    ${param4}   ${param5}  ${param6}
#@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}=   No X2 link available for a specific LTEENB
# ...                                  No X2 link available
#${TOP50}                             True
${GLO_SCOUT_TESTLINE_NAME}           1_5_UTE5G126
${EXECUTION_NUM}    ${100}

*** Test Cases ***

[1][1.0] Data Transfer
    [Tags]    SBTS24R3:QC_847904   QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=5880
    [Timeout]     72h
    #${extra_peak_rate_config}    Evaluate    {"301":[140,75],"302":[140,75],"303":[140,75]}
    test_fv.Data Transfer
    [Teardown]    Testcase Basic Postcondition

[3]Cell Block And Unblock All_with_resetBBMOD
    [Tags]    SBTS24R3:QC_847902   QCD_MN_RAN   QCP_RAN_ST
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
    [Tags]    SBTS24R3:QC_847903   QCD_MN_RAN   QCP_RAN_ST
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

[1][1.0] Deep Sleep Mode RU Lock and Unlock
    [Tags]    SBTS00:QC_55180    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Onair   config_id=5880
    [Timeout]     72h
    Deep Sleep Mode RU Lock and Unlock    rru_sn=1M203909482
    [Teardown]    Testcase Basic Postcondition

[5] General_SiSo_Auto_Automatic_RAT_SW_upgrade
    [Tags]    SBTS24R3:QC_847905   QCD_MN_RAN      QCP_RAN_ST
    [Setup]    Testcase UUF Precondition    case_name=UUF_kpi    config_id=5880
    SW Upgrade And RollBack KPI2    L3Call=YES
    [Teardown]     Testcase KPI postcondition

Common_SiSo_Startup_Onair
    [Tags]    SBTS00:QC_    SBTS24R1:QC_    QCD_MN_RAN  QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=5880
    FOR    ${index}    IN RANGE    0    ${EXECUTION_NUM}
        Log To Console     Site Reset times: ${index}+1
        Run Keyword And Ignore Error    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}
        Run Keyword And Ignore Error    Logging Multinode Start
        ${status}    ${return}    Run Keyword And Ignore Error    Site Reset
        Run Keyword IF    '${status}'=='FAIL'
        ...    Logging Multinode Stop      ${TEST_LOGS_DIR_PATH}/FAIL_${index}     test_status=FAIL
        Run Keyword IF    '${status}'=='FAIL'    FAIL
    END
    [Teardown]    Testcase Basic Postcondition

Common_SiSo_Block_Unblock_Cell
    [Tags]    SBTS00:QC_    SBTS24R1:QC_    QCD_MN_RAN  QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=5880
    FOR    ${index}    IN RANGE    0    ${EXECUTION_NUM}
        Log To Console     Cell Block&Unblock times: ${index}+1
        Run Keyword And Ignore Error    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}
        Run Keyword And Ignore Error    Logging Multinode Start
        ${status}    ${return}    Run Keyword And Ignore Error    Cell Block And Unblock All Without Call
        Run Keyword IF    '${status}'=='FAIL'
        ...    Logging Multinode Stop      ${TEST_LOGS_DIR_PATH}/FAIL_${index}     test_status=FAIL
        Run Keyword IF    '${status}'=='FAIL'    FAIL
    END
    [Teardown]    Testcase Basic Postcondition

Common_SiSo_Block_Unblock_Ru
    [Tags]    SBTS00:QC_    SBTS24R1:QC_    QCD_MN_RAN  QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=5880
    FOR    ${index}    IN RANGE    0    ${EXECUTION_NUM}
        Log To Console     RU Block&Unblock times: ${index}+1
        Run Keyword And Ignore Error    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}
        Run Keyword And Ignore Error    Logging Multinode Start
        ${status}    ${return}    Run Keyword And Ignore Error    Ru lock And Unlock Without Call
        Run Keyword IF    '${status}'=='FAIL'
        ...    Logging Multinode Stop      ${TEST_LOGS_DIR_PATH}/FAIL_${index}     test_status=FAIL
        Run Keyword IF    '${status}'=='FAIL'    FAIL
    END
    [Teardown]    Testcase Basic Postcondition

Common_SiSo_RU_Reset
    [Tags]    SBTS00:QC_    SBTS24R1:QC_    QCD_MN_RAN  QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=5880
    FOR    ${index}    IN RANGE    0    ${EXECUTION_NUM}
        Log To Console     RU Block&Unblock times: ${index}+1
        Run Keyword And Ignore Error    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}
        Run Keyword And Ignore Error    Logging Multinode Start
        ${status}    ${return}    Run Keyword And Ignore Error    RF module reset NoCall
        Run Keyword IF    '${status}'=='FAIL'
        ...    Logging Multinode Stop      ${TEST_LOGS_DIR_PATH}/FAIL_${index}     test_status=FAIL
        Run Keyword IF    '${status}'=='FAIL'    FAIL
    END
    [Teardown]    Testcase Basic Postcondition

Common_SiSo_BBMOD_Reset
    [Tags]    SBTS00:QC_    SBTS24R1:QC_    QCD_MN_RAN  QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=5880
    FOR    ${index}    IN RANGE    0    ${EXECUTION_NUM}
        Log To Console     BBMOD Reset times: ${index}+1
        Run Keyword And Ignore Error    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}
        Run Keyword And Ignore Error    Logging Multinode Start
        ${status}    ${return}    Run Keyword And Ignore Error    BBMOD Reset    bbmod_id_list=EA184380689:EA200950182:DH212563609
        Run Keyword IF    '${status}'=='FAIL'
        ...    Logging Multinode Stop      ${TEST_LOGS_DIR_PATH}/FAIL_${index}     test_status=FAIL
        Run Keyword IF    '${status}'=='FAIL'    FAIL
    END
    [Teardown]    Testcase Basic Postcondition

*** Keywords ***
BBMOD Reset
    [Documentation]    Auther: nick.1.wu@nokia-sbell.com
    [Arguments]    ${timeout}=300s    ${bbmod_id_list}=${Empty}    ${test_loops}=${Empty}
    #...    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        Reset BBMOD Until Onair    timeout=${timeout}    require_bbmod=${bbmod_id_list}    btsid=${bts_id}
        ...    test_loops=${test_loops}
    END
    Check Alarms
    Check Historical Alarms
    #Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Cell Block And Unblock All Without Call
     #[Arguments]    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
     FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Block Cell    ${cell_info}
     END

     FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Unblock Cell   ${cell_info}
     END
     Verify All Cells OnAir
     Check Alarms
     Check Historical Alarms    additional_allowed_alarms=Cell blocked:System information broadcast parameters overflow
     #Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
     Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Ru lock And Unlock Without Call
     [Documentation]   Auther: lisa.ding@nokia-sbell.com
     [Arguments]    ${timeout}=10 min
     FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
         Lock RU   ${btsId}
         Unlock RU   ${btsId}
     END
     Wait For All Cells OnAir    timeout=${timeout}
     #Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
     Check Multinode Without Unexpect Alarm
     Check Historical Alarms    additional_allowed_alarms=System information broadcast parameters overflow

RF module reset NoCall
    [Arguments]    ${required_power_rfs}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com
    ${required_power_rfs_list}    Split String    ${required_power_rfs}    :
    ${rf_list}    Set Variable If    "${required_power_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_power_rfs_list}
    ${cell_cross_rru}    Check Is Cell Cross RRU
    FOR    ${fr_serial_number}    IN    @{rf_list}
        Radio Reset    ${fr_serial_number}
    END
    Check Multinode Without Unexpect Alarm
    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Run Keyword If    ${cell_cross_rru}
    ...    Check Historical Alarms    additional_allowed_alarms=Transmission path failure:Tx Failure Turn Mimo Off
    ...    ELSE    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0


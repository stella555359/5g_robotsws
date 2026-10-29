*** Settings ***
#Force Tags
Documentation    Suite description
...    Author:        wei.ren@nokia-sbell.com
...    Maintainer:    weren

Library     Telnet
Library    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/kpiReporter.py
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/reportportal.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables    ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

Force Tags    CA_RAN_PZ_HAZ_1    SBTS00    RAN_5G    CRT    STATE_SW_UPLOADED

*** Variables ***
${peak1}    "660":[120,20],"661":[120,20],"662":[120,20],"663":[120,20],"675":[120,20],"665":[120,20]
${peak2}    "666":[120,20],"667":[120,20],"668":[120,20],"669":[120,20],"670":[120,20],"671":[120,20]
${peak3}    "676":[120,20],"690":[120,20],"610":[120,20]
${peak4}    "170":[140,20],"171":[140,20],"172":[140,20],"173":[140,20],"174":[140,20],"175":[140,20]
${peak5}    "186":[70,20],"187":[70,20],"188":[70,20],"179":[140,20],"180":[140,20],"181":[140,20]
${peak6}    "182":[70,20],"183":[70,20],"184":[70,20],"185":[70,20]
&{CB010746_B2}    HW_ID=ABIP   site_mode=5G    ONAIR_TIME=20 min
...	  peak_rate_config={${peak1},${peak2},${peak3},${peak4},${peak5},${peak6}}
&{CB012529_B}    HW_ID=ABIP   site_mode=5G    ONAIR_TIME=20 min
...	  peak_rate_config={${peak1},${peak2},${peak3},${peak4},${peak5},${peak6}}
&{call_issue_reproduce}    HW_ID=ABIP   site_mode=5G    ONAIR_TIME=20 min
...	  peak_rate_config={${peak1},${peak2},${peak3},${peak4},${peak5},${peak6}}
&{CB010640_CB012590}    HW_ID=ABIP   site_mode=5G    ONAIR_TIME=20 min
...	  peak_rate_config={${peak1},${peak2},${peak3},${peak4},${peak5},${peak6}}
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}     CB010746_B2
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitPartialReset    NgGnbInitFullReset    No module fan detected

${online_commissioning}    [['MRBTS-37039/LNBTS-37039/LNCEL-1/LNCEL_FDD-0',['dlChBw','10 MHz']],
...                         ['MRBTS-37039/LNBTS-37039/LNCEL-1/LNCEL_FDD-0',['ulChBw','10 MHz']],
...                         ['MRBTS-37039/LNBTS-37039/LNCEL-1',['actDownSampling','false']]]

${prach_parameters}    [['MRBTS-37039/NRBTS-37039',['actAutoPrachConfigIndexFdd','true']],
...                     ['MRBTS-37039/NRBTS-37039',['actAutoPrachConfigIndexFddEnh','true']],
...                     ['MRBTS-37039/NRBTS-37039/NRDU-1',['crntiAllocationOption','max72cellsEnh']]]
${GLO_PERFORM_SAVE_LOG}    FAIL
${INIT_SW_VERSION}    {'37039': 'SBTS24R1_ENB_0000_000009_000000'}
${TARGET_SW_VERSION}    {'37039': 'SBTS00_ENB_9999_231013_000009'}
${RB_TO_TARGET}    YES
${YAFT}    YES
${TDD_OR_FDD}    FDD
${SPECIFIC_BRANCH}     Yes
${TOP50}                             True
${RU}    3AREA+2FRPA+3AHEGC+2AHHB
${SA_OR_NSA}
${HW_ID}    1ASIM+1ABIP+3AREA+2FRPA+3AHEGC+2AHHB
&{ADDITIONAL_FLAGS}    37039=0x4200AA=1
*** Test Cases ***
#CB010746
#[1][1] Common_SiSo_State Management_Cell_Block_Unblock
 #   [Tags]    QC_33185   QCD_MN_RAN   QCP_RAN_VRF
  #  [Setup]    Testcase Basic Precondition    case_name=Cell_Block    config_id=CB012529_B
   # Cell Block And Unblock All    required_cells=665
    #[Teardown]    Testcase Basic Postcondition

[1][1] Common_SiSo_Call_Throughput_Measurements_UDP
    [Tags]    QC_146136  QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=CB010640_CB012590
    test_fv.Data Transfer    required_cells=665
    [Teardown]    Testcase Basic Postcondition

[1][1.0] [1.1]Common_SiSo_Configuration Management_Delta plan Commissioning
    [Tags]    QC_146135   QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=delta_commission    config_id=CB010640_CB012590
    Automated SiSo OnLine Parameters Commissioning    required_cells=665
    [Teardown]    Testcase Basic Postcondition

[1] Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Tags]    QC_146099    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    ...    config_id=CB012529_B
    [Timeout]    72h
    Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock    required_cells=665
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_Cell block_Then_RF reset_Then_Cell unblock
    [Tags]    QC_146098    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=CB010640_CB012590
    Cell Block And Unblock All with rfreset    required_cells=665
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_Cell Block&unblock_Then_RF Lock&Unlock
    [Tags]    QC_146100    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=CB012529_B
    Cell Block And Unblock All    required_cells=665
    Append To List    ${GLO_ADMIN_ALLOWED_ALARM}    Cell blocked
    Ru lock And Unlock All    required_cells=665
    [Teardown]    Testcase Basic Postcondition

[1] Manual_SiSo_SM_LTE_RAT_reset_for_concurrent
   [Tags]    QC_146101    QCD_MN_RAN    QCP_RAN_VRF
   [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm    config_id=CB012529_B
   RAT reset from WebEm For LTE testline        required_cells=665
   [Teardown]    Testcase Basic Postcondition

[1] Manual_SiSo_SM_NR_RAT_reset_for_concurrent
    [Tags]    QC_146102    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm    config_id=CB012529_B
    RAT reset from WebEm For NR testline       required_cells=665
    [Teardown]    Testcase Basic Postcondition

[1][2.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]    QC_146133     QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Testcase UUF Precondition    case_name=UUF_kpi    config_id=CB010746_B2
    [Timeout]    72h
    SW Upgrade And RollBack KPI2    L3Call=NO
    [Teardown]     Testcase KPI postcondition

Reproduce_Call_Throughput_Measurements_UDP
    [Tags]    QC_104050  QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=call_issue_reproduce
    test_fv.Data Transfer    required_cells=185
    [Teardown]    Testcase Basic Postcondition

Common_Siso_CM_operation_exploratory_test
    [Tags]    QC_146134     QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=test    config_id=CB012529_B
    FOR    ${num}    IN RANGE    ${3}
        log to console    \n************************${num}**********************\n
        Common_SiSo_Recovery_RF module reset_Then_BBMOD_reset
        #RF lock And Unlock with BTS Reset
        Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
        #Stability Site Reset
        Common_SiSo_Recovery_RF_module_reset_Then_RAT_reset
    END
    [Teardown]    Testcase Basic Postcondition

# CB010448
CB0010448-BC#1_Activation_and_deactivation_of_automated_prachConfigurationIndex_assignment_for_FDD_cells_withPreambleFormat0
    [Tags]    QC_33187   QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=withPreambleFormat    config_id=CB010746_B2
    ${bts_id}    Set Variable    37039
    ${scfc_file_path}    Replace String Using Regexp    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    ...    CONF_${NODE_CFG["${bts_id}"]["id"]}    withPreambleFormat0
    Activation_and_deactivation_of_automated_prachConfigurationIndex_assignment
    ...    ${scfc_file_path}    ${bts_id}    required_cells=665
    [Teardown]    Testcase Basic Postcondition

CB0010448-BC#3_ Activation_and_deactivation_of_automated_prachConfigurationIndex_assignment_for_FDD_mixed_prachPreambleFormat
    [Tags]    QC_33188    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=mixed_prachPreambleFormat
    ${bts_id}    Set Variable    37039
    ${scfc_file_path}    Replace String Using Regexp    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    ...    CONF_${NODE_CFG["${bts_id}"]["id"]}    mixed_PreambleFormat
    Activation_and_deactivation_of_automated_prachConfigurationIndex_assignment
    ...    ${scfc_file_path}    ${bts_id}    required_cells=665
    [Teardown]    Testcase Basic Postcondition

*** Keywords ***
Activation_and_deactivation_of_automated_prachConfigurationIndex_assignment
    [Arguments]    ${scfc_file_path}    ${bts_id}    ${required_cells}=${EMPTY}
    ${connection}    Set Variable    ${CASE_NAME}_${bts_id}
    coam.Perform Commissioning
    ...    ${bts_id}    ${scfc_file_path}    skip_parameter_relation_errors=False
    ...    should_activate=True    timeout=1200    connection=${connection}
    Verify HW state
    ute_admin_infomodel.setup_infomodel    alias=prachConfig
    ute_admin_infomodel.connect_infomodel    alias=prachConfig
    ute_admin_infomodel.query_infomodel
    ...    count //MCTRL-1/BBTOP_M-1/MRBTS_M-1/NRBTS_M-1/CELL_M-* is [stateInfo.proceduralState=regex"(?i)onAirDone"] = 3
    ...    timeout=1000   alias=prachConfig
    ute_admin_infomodel.query_infomodel
    ...    count //MCTRL-1/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-* is [stateInfo.proceduralState=regex"(?i)onAirDone"] = 16
    ...    timeout=120   alias=prachConfig
    ute_admin_infomodel.query_infomodel    count /MRBTS-1/RAT-1/FRI-1/ALARM-* is [faultId=4676] = 9    timeout=120   alias=prachConfig
    ute_admin_infomodel.query_infomodel    count /MRBTS-1/RAT-1/FRI-1/ALARM-* is [faultId=1868] = 3    timeout=120   alias=prachConfig
    Perform Parameters Commissioning
    ...    ${bts_id}   ignore_errors=False    connection=${connection}    online_commissioning_tmp=${prach_parameters}
    Verify HW State
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Make L3Call    required_cells=${required_cells}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms    additional_allowed_alarms=Duplicate PRACH configuration index:BTS configuration error.*
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=1
    [Teardown]    Run Keyword And Ignore Error    Run Keywords    ute_admin_infomodel.disconnect_infomodel    alias=prachConfig
    ...    AND    ute_admin_infomodel.teardown_infomodel    alias=prachConfig

Wait For GPS Self Check
    ${status}    Run Keyword And Return Status    Check Alarm Is Appear    37039    faultId=regex"4405|4420"
    Return From Keyword If    not ${status}
    ${status}    Wait For Complete
    Should Be True    ${status}

Wait For Complete
    FOR    ${i}    IN RANGE    ${20}
        ${gps_info}    coam.get_gps_status    connection=${CASE_NAME}_37039
        ${selfSurveyStatus}    Set Variable    ${gps_info["gnsse"][0]["parameters"]["selfSurveyStatus"]}
        Return From Keyword If    "${selfSurveyStatus}"=="Completed"    ${True}
        sleep    10 min
    END
    ${gps_info}    coam.get_gps_status    connection=${CASE_NAME}_37039
    ${selfSurveyStatus}    Set Variable    ${gps_info["gnsse"][0]["parameters"]["selfSurveyStatus"]}
    ${gnsse_distname}    Set Variable    ${gps_info["gnsse"][0]["id"]["internal"]}
    Run Keyword If    "${selfSurveyStatus}"=="In progress 99%"    coam.reset unit    ${gnsse_distname}    connection=${CASE_NAME}_37039
    sleep    5 min
    FOR    ${i}    IN RANGE    ${20}
        ${gps_info}    coam.get_gps_status    connection=${CASE_NAME}_37039
        ${selfSurveyStatus}    Set Variable    ${gps_info["gnsse"][0]["parameters"]["selfSurveyStatus"]}
        Return From Keyword If    "${selfSurveyStatus}"=="Completed"    ${True}
        sleep    10 min
    END
    Return From Keyword    ${False}

Testcase Precondition With GPS Check
    [Arguments]    ${case_name}    ${config_id}=${EMPTY}    ${force_recommission}=${False}
    Close Multi Node Process
    Set Test Variable    ${CASE_NAME}    ${case_name}
    Set TC Dir Path
    Create Nodes Parameters Init    ${config_id}    force=False
    Update Qc Id Tag
    Run Keyword If    "${${CURRENT_CONFIG_ID}.site_mode}"!="4G"    Run Keyword And Ignore Error
    ...    Get Resource Usage Setup    aashell_name=aashell
    Logging Multinode Start    ${TEST_LOGS_DIR_PATH}/setup
    ${out_SAS_SIM_config}    Run Keyword And Return Status    Variable Should Exist    ${tl_config.SAS_SIM}
    ${out_need_SAS_SIM}    Set Variable If     ${out_SAS_SIM_config}      ${tl_config.SAS_SIM}    False
    Run Keyword If     "${out_need_SAS_SIM}"=="True"    Run Keywords    Restart SAS Simulator
    ...    AND    Sleep    2 min
    Log Dictionary    ${NODE_CFG}
    Change Testline Configuration    ${config_id}    force_recommission=${force_recommission}
    ${status}    Run Keyword If    "${NOT_COMMISSIONED}"=="True"    Run Keyword And Return Status    Verify All Cells OnAir
    ${status}    Run Keyword And Return Status    Run Keyword If    "${NOT_COMMISSIONED}"=="True" and "${status}" == "False"
    ...    Reset BTS Until Onair    timeout=${ONAIR_TIME}
    ...    ELSE IF    "${NOT_COMMISSIONED}"=="False"    Run Keywords    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    ...    AND    Check Default Value Of Parameter
    Run Keyword If    not ${status}    Run Keywords    Wait For GPS Self Check
    ...    AND    Check All Cells OnAir
    Check Multinode Without Unexpect Alarm
    [Teardown]    Run Keyword If    "${KEYWORD STATUS}"=="PASS"    Run Keywords
    ...    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}/setup/
    ...    AND    Logging Multinode Start
    ...    AND    Logging Gnb Admin Start
    ...    AND    Get And Check Reset Counter For All BTS Node


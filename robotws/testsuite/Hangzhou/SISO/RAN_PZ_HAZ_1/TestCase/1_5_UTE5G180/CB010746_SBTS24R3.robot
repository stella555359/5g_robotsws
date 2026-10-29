*** Settings ***
#Force Tags
Documentation    Suite description
...    Author:        wei.ren@nokia-sbell.com
...    Maintainer:    weren

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables   ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${peak1}    "660":[120,20],"661":[120,20],"662":[120,20],"663":[120,20],"675":[120,20],"665":[120,20]
${peak2}    "666":[120,20],"667":[120,20],"668":[120,20],"669":[120,20],"670":[120,20],"671":[120,20]
${peak3}    "676":[120,20],"690":[120,20],"610":[120,20]
${peak4}    "170":[140,20],"171":[140,20],"172":[140,20],"173":[140,20],"174":[140,20],"175":[140,20]
${peak5}    "186":[70,20],"187":[70,20],"188":[70,20],"179":[140,20],"180":[140,20],"181":[140,20]
${peak6}    "182":[70,20],"183":[70,20],"184":[70,20],"185":[70,20]
&{CB010746_B2}    HW_ID=ABIP   site_mode=5G    ONAIR_TIME=20 min
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

*** Test Cases ***
#CB010746
[1][1] Common_SiSo_State Management_Cell_Block_Unblock
    [Tags]    QC_862440   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block    config_id=CB010746_B2
    Cell Block And Unblock All    required_cells=665
    [Teardown]    Testcase Basic Postcondition

[1][1] Common_SiSo_Call_Throughput_Measurements_UDP
    [Tags]    QC_862443  QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=CB010746_B2
    test_fv.Data Transfer    required_cells=665
    [Teardown]    Testcase Basic Postcondition

[1][1.0] [1.1]Common_SiSo_Configuration Management_Delta plan Commissioning
    [Tags]    QC_862441   QCD_MN_RAN   QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=delta_commission    config_id=CB010746_B2
    Automated SiSo OnLine Parameters Commissioning    required_cells=665
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


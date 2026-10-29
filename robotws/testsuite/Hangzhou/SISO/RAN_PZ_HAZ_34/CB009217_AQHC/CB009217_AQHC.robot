*** Settings ***
Documentation    This is for CB009217 AQHC regression

Suite Setup          SBTS Suite Setup
Suite Teardown       SBTS Suite Teardown
Test Setup           SBTS Test Setup    allowed_faults_ids=4291
Test Teardown        SBTS Test Teardown    allowed_faults_ids=4291
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot

Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed.robot
Resource    ${BASIC_PATH_LTE}/Manual_SiSo_SM_RF_Module_lock_unlock.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_Beamforming_Calibration_Cal_Software_Component_Operation_Verification.robot
Resource    ${BASIC_PATH_LTE}/Manual_SiSo_SM_LTE_RAT_reset.robot
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot

Resource    ${BASIC_PATH_LTE}/Manual_SiSo_SM_BTS_Site_Reset.robot


Force Tags

*** Variables ***
${if_commissioning}   True
${ssh_username}      ${tl.enbs[0].system_module.common_units[0].lmp_connection.username}
${ssh_password}      ${tl.enbs[0].system_module.common_units[0].lmp_connection.password}


*** Test Cases ***
[1]CB009217-SR-G_05_AQHC_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1]CB009217-SR-G_07_AQHC_General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
    AlarmWatchdog.add_allow_alarms    fault_id=1900
    AlarmWatchdog.add_allow_alarms    fault_id=4008
    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
    AlarmWatchdog.remove_allow_alarms    fault_id=1900
    AlarmWatchdog.remove_allow_alarms    fault_id=4008

[1]CB009217-SR-G_06_AQHC_General_SiSo_Commissioning_BTS_Template_Commissioning
    General_SiSo_Commissioning_BTS_Template_Commissioning

[1]CB009217-SR-G_03_AQHC_General_SiSo_Beamforming_Calibration_Cal_Software_Component_Operation_Verification
    General_SiSo_Beamforming_calibration_Cal_Software_Component_Operation_Verification

[1]CB009217-SR-G_16_AQHC_Manual_SiSo_CALL_LTE_data_call_3xLTE20M
    ${lte_cell_id_list}    Get All Cell Id    cell_type=lte
    Simple UE L3 Call And Throughput    cell_list=${lte_cell_id_list}    dl_tp=120   ul_tp=17
    ...    target_avg_percent=0.8   min_percent=0.5
    ...    duration=${200}

[1]CB009217-SR-J_05_AQHC_Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]    1S_4cc
    Manual_SiSo_SM_RF_Module_lock_unlock    with_call=False


[1]CB009217-SR-G_18_AQHC_Manual_SiSo_CALL_LTE_data_call_2xLTE20M+LTE15M
    ${SCF_Path}    Replace String    ${Golden_SCF_Path}    .xml    _20_20_15.xml
    Commissioning SCF And Check On Air for Common    scf_path=${SCF_Path}
    ${lte_cell_id_list}    Get All Cell Id    cell_type=lte
    Simple UE L3 Call And Throughput    cell_list=${lte_cell_id_list}    dl_tp=85   ul_tp=12
    ...    target_avg_percent=0.8   min_percent=0.5    scf_path=${SCF_Path}
    ...    duration=${200}

[1]CB009217-SR-J_11_AQHC_Manual_SiSo_CALL_LTE_data_call_4xLTE20M
    ${lte_cell_id_list}    Get All Cell Id    cell_type=lte
    ${SCF_Path}    Replace String    ${Golden_SCF_Path}    .xml    _1S_4cc.xml
    Commissioning SCF And Check On Air for Common    scf_path=${SCF_Path}
    Simple UE L3 Call And Throughput    cell_list=${lte_cell_id_list}    dl_tp=120    ul_tp=17
    ...    target_avg_percent=0.8   min_percent=0.5
    ...    duration=${200}    scf_path=${SCF_Path}

*** Keywords ***
SBTS Suite Setup
    robot_common_operations.Common Suite Setup
    log to console    \n***SBTS Suite Setup***
    run keyword and ignore error    clear vm pid before run case
    run keyword if     ${if_commissioning} and '${testline_name}' == 'null'    CI_interface.Common Suite Setup
    ${pingable}    Run Keyword And Return Status    Check SBTS Ping Enable    bts_host=${sbts_addr}
    ${sbts_addr_temp}    set variable if    ${pingable}==${False}    192.168.255.129   ${sbts_addr}
    Connect to gnb coam via ssl    bts_host=${sbts_addr_temp}    username=${http_username}
    ...    password=${http_password}
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get SBTS SCF File Path    sw_version=${Active_SW_version}
#	@{split_version}    string.split string    ${Active_SW_version}    separator=_
#    ${stream}    set variable     ${split_version}[0]
#    ${version}=    Set Variable If
#    ...     '${stream}'=='SBTS24R1'        SBTS24R1
#    ...     '${stream}'=='SBTS24R3'        SBTS24R3
#    ...     '${stream}'=='SBTS24R2'        SBTS24R2
#    ...     '${stream}'=='SBTS23R4'        SBTS23R4
#    ...     SBTS25R1
#	${SCF_Path}    run keyword if    '${version}'=='SBTS25R1'    Replace String    ${Golden_SCF_Path}    .xml
#	...    _20_15_10.xml
#    ...    ELSE     Replace String    ${Golden_SCF_Path}    .xml    _20_20_20.xml
    ${SCF_Path}    Replace String    ${Golden_SCF_Path}    .xml    _20_20_20.xml
    Commissioning SCF And Check On Air for Common    scf_path=${SCF_Path}
    set suite variable      ${Golden_SCF_Path}
    Generate SBTS Suite Log Path
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    bts_host=${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    add fault to the allowed fault list    faultId=${4681}
    add fault to the allowed fault list    faultId=${4291}
    log to console  MRBTS_ID:${MRBTS_ID}, NRBTS_ID:${NRBTS_ID}


SBTS Suite Teardown
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}
    ...    password=${http_password}
    Commissioning SCF And Check On Air for Common    scf_path=${Golden_SCF_Path}
    robot_common_operations.Common Suite Teardown
    log to console    \n***SBTS Suite Teardown***
    COAM Teardown gnb connections
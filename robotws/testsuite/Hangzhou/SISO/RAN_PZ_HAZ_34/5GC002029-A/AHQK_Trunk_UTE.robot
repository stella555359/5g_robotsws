*** Settings ***
Documentation
...    Author:Chen Yin
...    contact:yin.1.chen@nokia-sbell.com
...    squad group:5G_PZ_HZ_2_SG
...    Feature 5GC002029, 5GC001821, 5GC000702, FGCR-4099

Force Tags        master_classicalbts_all      5G_RAN_TDD    CLOUD_5G_CLASSICAL_ASIBR_ABILB1B2_AHQK_ENB
...    PY39
...          CIT     5G_RAN    SBTS00      STATE_SW_UPLOADED      RAN_5G      RAN_5G_TDD
Suite Setup          SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${True}
Suite Teardown       Common Suite Teardown with Recover Env
Resource          Resources/5GC002029_A_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010823_AHQK/Resources/CB010823_common_keywords.robot
Library           testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010823_AHQK/Resources/Update_key_value.py
Library           ./Resources/get_zip_by_filter.py
Library           taf.selenium.sbts   WITH NAME   selenium_sbts

*** Variables ***
${1S_1CC_2DL2UL}    1S_1CC_2DL2UL.xml
${1S_1CC_4DL2UL}    1S_1CC_4DL2UL.xml
${2S_1CC_2DL2UL}    2S_1CC_2DL2UL.xml
${2S_1CC_4DL2UL}    2S_1CC_4DL2UL.xml
&{fault_61524}             faultId=${61524}    #SSH enabled
&{fault_61652}             faultId=${61652}    #R&D Service Port enabled
&{fault_4654}              faultId=${4654}    #Ethernet port security is disabled
&{fault_4655}              faultId=${4655}    #Service account root access is enabled
&{fault_4681}              faultId=${4681}    #Sanity Check Error
&{fault_61649}              faultId=${61649}    #LMP access via port 443
&{fault_4592}               faultId=${4592}     #BTS Reset Cause
@{allowed_faults}    &{fault_61524}    &{fault_61652}    &{fault_4654}    &{fault_4655}    &{fault_4681}
              ...    &{fault_61649}    &{fault_4592}
${btslog_path}    /opt/btslog/btslog
${btslog_launcher_path}    /opt/btslog/btslog_launcher
${btslog_folder}    /tmp/btslog2
@{WEBEM_RADIO_MODUDLES}    RMOD_R-1    RMOD_R-2
@{CLI_RADIO_MODUDLES}    MRBTS-226/EQM_R-1/APEQM_R-1/RMOD_R-1    MRBTS-226/EQM_R-1/APEQM_R-1/RMOD_R-2
@{POINT_41_WEBEM}    41 - RU Memory usage
@{POINT_42_WEBEM}    42 - RU Temperature sensor
@{POINT_41_42_WEBEM}    41 - RU Memory usage    42 - RU Temperature sensor
&{CUSTOM_CHECK_41_42_WEBEM}    RMOD-1 / RMOD_R-1 (AHQK)=@{POINT_41_42_WEBEM}
...    RMOD-2 / RMOD_R-2 (AHQK)=@{POINT_41_42_WEBEM}

*** Test Cases ***
[2][1.1] General_SiSo_Commissioning_BTS_Template_Commissioning
    [Timeout]      2h
    [Setup]    UTE Common Case Setup      scf_path=${1S_1CC_2DL2UL}    ru_list=${1}
    ${current_scf}=    Get Current SCF file    dir=${log_path}
    Run keyword and ignore error    COAM Commission with scf file    scf_file_path=${current_scf}    timeout=600
    COAM Wait for gnb ready and cell setup    timeout=15min
    [Teardown]    Test Case Teardown

[2][1.0] General_SiSo_RF_module_power_reset
    [Setup]    Test Case Setup
    @{ignore_list}      Create List      10      4589
    @{use_ru_list}    Create List    1
    AlarmWatchdog.add_allow_alarms    fault_id=@{ignore_list}
    Power Off RU and Check Status    ru_list=${use_ru_list}
    Power On RU and Check Status    ru_list=${use_ru_list}    allowed_faults=${allowed_faults}
    AlarmWatchdog.remove_allow_alarms    fault_id=@{ignore_list}
    [Teardown]    Test Case Teardown

[1][1.0] General_SiSo_Cell_lock_and_unlock
    [Setup]    Test Case Setup
    COAM Wait for gnb ready and cell setup
    @{use_cell_list}    Create List    1
    Lock Cell and Check Status    cell_list=${use_cell_list}      gnb_type=SA
    Unlock Cell and Check Status    allowed_faults=${allowed_faults}    cell_list=${use_cell_list}
    @{use_cell_group_list}    Create List    0
    Lock Cell Group and Check Status    cell_group_list=${use_cell_group_list}      gnb_type=SA      branch=${ENB_BUILD}
    Unlock Cell Group and Check Status    allowed_faults=${allowed_faults}    cell_group_list=${use_cell_group_list}
    ...      branch=${ENB_BUILD}
    [Teardown]    Test Case Teardown

[1][1.0] General_SiSo_RU_lock_unlock
    [Setup]    Test Case Setup
    COAM Wait for gnb ready and cell setup
    @{use_ru_list}    Create List    1
    Lock RU and Check Status    ru_list=${use_ru_list}      gnb_type=SA
    Unlock RU and Check Status    allowed_faults=${allowed_faults}    ru_list=${use_ru_list}
    [Teardown]    Test Case Teardown

[1][1.0] General_SiSo_RU_module_reset_from_GUI
    [Setup]    UTE Common Case Setup      scf_path=${1S_1CC_4DL2UL}    ru_list=${1}
    COAM Wait for gnb ready and cell setup
    @{use_ru_list}    Create List    1
    Reset RU and Check Status    allowed_faults=${allowed_faults}    ru_list=${use_ru_list}
    [Teardown]    Test Case Teardown

[1][1.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Setup]    Test Case Setup
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_alias=RU_1    ru_index=1
    Verify RFSW Log Include In Snapshot    ru_alias=RU_1    ru_index=1
    [Teardown]    Test Case Teardown

[2][1.0] General_SiSo_RU_lock_unlock
    [Setup]    Test Case Setup
    COAM Wait for gnb ready and cell setup
    @{use_ru_list}    Create List    1
    Lock RU and Check Status    ru_list=${use_ru_list}      gnb_type=SA
    Unlock RU and Check Status    allowed_faults=${allowed_faults}    ru_list=${use_ru_list}
    [Teardown]    Test Case Teardown

[2][1.0] General_SiSo_Cell_lock_and_unlock
    [Setup]    Test Case Setup
    COAM Wait for gnb ready and cell setup
    @{use_cell_list}    Create List    1
    Lock Cell and Check Status    cell_list=${use_cell_list}      gnb_type=SA
    Unlock Cell and Check Status    allowed_faults=${allowed_faults}    cell_list=${use_cell_list}
    @{use_cell_group_list}    Create List    0
    Lock Cell Group and Check Status    cell_group_list=${use_cell_group_list}      gnb_type=SA
    ...      branch=${ENB_BUILD}
    Unlock Cell Group and Check Status    allowed_faults=${allowed_faults}    cell_group_list=${use_cell_group_list}
    ...      branch=${ENB_BUILD}
    [Teardown]    Test Case Teardown

[2][1.0] General_SiSo_Auto_RF_module_reset_from_WebUI
    [Setup]    Test Case Setup
    @{use_ru_list}    Create List    1
    Reset RU and Check Status    allowed_faults=${allowed_faults}    ru_list=${use_ru_list}
    [Teardown]    Test Case Teardown

[1][1.0] General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Setup]    UTE Common Case Setup      scf_path=${2S_1CC_2DL2UL}        ru_list=${2}
    Connect to Common Unit Master
    Connect to RU With Allocated IP      ru_index=1
    COAM verify ru sw version    ru_resource_build_key=LTX_AHQK_E1
    Connect to RU With Allocated IP      ru_index=2
    COAM verify ru sw version    ru_resource_build_key=LTX_AHQK_E1
    [Teardown]    Test Case teardown

[1][1.0] General_SiSo_RF_module_power_reset
    [Setup]    Test Case Setup
    @{use_ru_list}    Create List    1      2
    Power Off RU and Check Status    ru_list=${use_ru_list}
    Power On RU and Check Status    ru_list=${use_ru_list}    allowed_faults=${allowed_faults}
    [Teardown]    Test Case Teardown

[1][1.0] General_SiSo_Auto_gNB_Site_Reset_From_WebUI
    [Setup]    UTE Common Case Setup      scf_path=${2S_1CC_4DL2UL}        ru_list=${2}
    ${active_fault}    COAM Get active alarms
    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20min
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
    [Teardown]    Test Case Teardown

[1][1.0] General_SiSo_Auto_RF_module_reset_from_WebUI
    [Setup]    Test Case Setup
    COAM Wait for gnb ready and cell setup
    @{use_ru_list}    Create List    1     2
    Reset RU and Check Status    allowed_faults=${allowed_faults}    ru_list=${use_ru_list}
    [Teardown]    Test Case Teardown

[1]General_SiSo_Commissioning_BTS_Template_Commissioning
    [Setup]    Test Case Setup
    ${current_scf}=    Get Current SCF file    dir=${log_path}
    Run keyword and ignore error    COAM Commission with scf file    scf_file_path=${current_scf}    timeout=600
    COAM Wait for gnb ready and cell setup    timeout=15min
    [Teardown]    UTE Common Case Teardown

[1]CB007042-B_05_L1low_dump_capture
    [Setup]    Test Case Setup
    Troubleshooting Scripts for Radio module    script_name=RU_Common_capture_L1low_data
    [Teardown]    Test Case Teardown

[1]CB007042-B_04_Register_dump_capture
    [Setup]    Test Case Setup
    Troubleshooting Scripts for Radio module    script_name=RU_Common_capture_register_dump
    [Teardown]    Test Case Teardown

[1]CB007042-B_03_RF_IQ_data_capture
    [Setup]    UTE Common Case Setup      scf_path=${2S_1CC_4DL2UL}        ru_list=${2}
    Troubleshooting Scripts for Radio module    script_name=RU_Common_capture_IQ_data
    [Teardown]    Test Case Teardown

[1]CB010823_SR_A_01_Run_Full_Diagnostic_check_online_from_WebEM
    [Setup]    UTE Common Case Setup      scf_path=${2S_1CC_4DL2UL}        ru_list=${2}
    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20 min
    sleep    5min
    COAM Navigate to login page via webUI
    ${full_diagnostic_report}   selenium_sbts.get_report
    ${RUfullreport}    set variable    ${full_diagnostic_report['RU diagnostic check report']}
    CheckRUReport    RUreport=${RUfullreport}    checkID=${41}    CheckPoint=RU Memory usage    TriggerType=Automatic
    CheckRUReport    RUreport=${RUfullreport}    checkID=${42}    CheckPoint=RU Temperature sensor    TriggerType=Automatic
    COAM selenium close browser
    COAM Navigate to login page via webUI
    selenium_sbts.start_diagnostic_check   scope=Full diagnostic check      allow_service_impact=${False}
    sleep   60s
    ${full_diagnostic_report}   selenium_sbts.get_report
    ${RUfullreport}    set variable    ${full_diagnostic_report['RU diagnostic check report']}
    CheckRUReport    RUreport=${RUfullreport}    checkID=${41}    CheckPoint=RU Memory usage    TriggerType=WebEM
    CheckRUReport    RUreport=${RUfullreport}    checkID=${42}    CheckPoint=RU Temperature sensor    TriggerType=WebEM
    selenium_sbts.start_diagnostic_check   scope=Full diagnostic check      allow_service_impact=${True}
    sleep   5min
    COAM selenium close browser
    COAM Navigate to login page via webUI
    Wait Until Keyword Succeeds    5 min    3 sec    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5 min    3 sec    COAM Check GNB cell on air
    ${full_diagnostic_report}   selenium_sbts.get_report
    ${RUfullreport}    set variable    ${full_diagnostic_report['RU diagnostic check report']}
    CheckRUReport    RUreport=${RUfullreport}    checkID=${41}    CheckPoint=RU Memory usage    TriggerType=WebEM
    CheckRUReport    RUreport=${RUfullreport}    checkID=${42}    CheckPoint=RU Temperature sensor    TriggerType=WebEM
    [Teardown]    Run keywords      COAM selenium close browser       AND      CB010823 Test case Teardown

[1]CB010823-SR-A_2_Run RF Diagnostic check online from WebEM
    [Setup]    Test Case Setup
    COAM Navigate to login page via webUI
    selenium_sbts.start_diagnostic_check   scope=Customized diagnostic check        radio_checkpoints=${CUSTOM_CHECK_41_42_WEBEM}
    sleep   60s
    ${full_diagnostic_report}   selenium_sbts.get_report
    ${RUfullreport}    set variable    ${full_diagnostic_report['RU diagnostic check report']}
    CheckRUReport    RUreport=${RUfullreport}    checkID=${41}    CheckPoint=RU Memory usage    TriggerType=WebEM
    CheckRUReport    RUreport=${RUfullreport}    checkID=${42}    CheckPoint=RU Temperature sensor    TriggerType=WebEM
    [Teardown]    Run keywords      COAM selenium logout       AND      CB010823 Test case Teardown

[1]CB010823-SR-A_3_Run FULL Diagnostic check from WebEM Remote tool
    [Setup]    Test Case Setup
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${diagnostic_result}    coam.run_diagnostic_check    connection=GNB_OAM
    CheckRUReport_CLI    RUreport=${diagnostic_result}    checkID=${41}    CheckPoint=RU Memory usage
    ...      TriggerType=WebEMRemoteTool      dist_Name=${CLI_RADIO_MODUDLES}
    CheckRUReport_CLI    RUreport=${diagnostic_result}    checkID=${42}    CheckPoint=RU Temperature sensor
    ...      TriggerType=WebEMRemoteTool      dist_Name=${CLI_RADIO_MODUDLES}
    [Teardown]    CB010823 Test case Teardown

[1]CB010823-SR-A_5_Check Diagnosctic Report
    [Documentation]    Trigger CP41 NOK case
    [Setup]    Test Case Setup
    Modify memoryTestThreshold in json file      memoryTestThreshold=10
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${diagnostic_result}    coam.run_diagnostic_check    connection=GNB_OAM
    CheckRUReport_CLI    RUreport=${diagnostic_result}    checkID=${41}    CheckPoint=RU Memory usage
    ...      TriggerType=WebEMRemoteTool      dist_Name=${CLI_RADIO_MODUDLES}      checking_status=NOK
    [Teardown]    Run keywords      Modify memoryTestThreshold in json file      memoryTestThreshold=100
    ...      AND      CB010823 Test case Teardown

[1]CB010823-SR-A_7_Check 4681 fault in NOK cases
    [Setup]    Test Case Setup
    Trigger CP42 NOK case
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${diagnostic_result}    coam.run_diagnostic_check    connection=GNB_OAM
    CheckRUReport_CLI    RUreport=${diagnostic_result}    checkID=${42}    CheckPoint=RU Memory usage
    ...      TriggerType=WebEMRemoteTool      dist_Name=${CLI_RADIO_MODUDLES}      checking_status=NOK
    [Teardown]    Run keywords      Clear FID1171      AND      CB010823 Test case Teardown

[1]CB010823-SR-A_9_Automatic Execution of Diagnostic check from webEM with cell onAir
    [Setup]    Test Case Setup
    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20 min
    Login webEM
    sleep   60s
    ${full_diagnostic_report}   selenium_sbts.get_report
    ${RUfullreport}    set variable    ${full_diagnostic_report['RU diagnostic check report']}
    CheckRUReport    RUreport=${RUfullreport}    checkID=${41}    CheckPoint=RU Memory usage    TriggerType=Automatic
    CheckRUReport    RUreport=${RUfullreport}    checkID=${42}    CheckPoint=RU Temperature sensor    TriggerType=Automatic
    [Teardown]    CB010823 Test case Teardown


*** Keywords ***
Recover Environment for AHQK
    [Arguments]   ${scf_path}
    ...    ${cur_relative_dir}=testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002029-A
    robot_common_operations.Common Suite Teardown
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    @{all_ru_list}    Create List    1    2
    FOR    ${r_list}    IN    @{all_ru_list}
         Perform RU Power On    ru_index=${r_list}
         ...    model=${tl.gnbs[${0}].dus[${0}].rus[${r_list}-1].pdu_port.pdu.__class__.__name__}
    END
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Commissioning with Template Commission      scf_file=${scf_base_path}/7_5_UTE5G402T225/${scf_path}

Common Suite Teardown with Recover Env
    Recover Environment for AHQK    scf_path=2S_1CC_4DL2UL.xml
    robot_common_operations.Common Suite Teardown

Troubleshooting Scripts for Radio module
    [Arguments]  ${script_name}
    ${cells_name}    create list    MRBTS-225/NRBTS-225/NRCELL-1    MRBTS-225/NRBTS-225/NRCELL-2
    ${mods_name}    create list    MRBTS-225/EQM-1/APEQM-1/RMOD-1      MRBTS-225/EQM-1/APEQM-1/RMOD-2
    Run  rm -rf /tmp/*SCRIPT_RESULT*
    Connect to gnb coam via ssl
    ${status}    coam.launch_troubleshooting_script    script_name=${script_name}
    ...    output_file_name=${TS_CASE_LOG_PATH}/script_result_011_${script_name}.zip
    ...    cell_list=${cells_name}    rmod_list=${mods_name}
    ...    free_parameters=${EMPTY}    timeout=900    connection=GNB_OAM
    Should Be Equal    ${status}    Launching succeeded. Snapshot has been successfully created.
    ${script_zip_file_path}      Set Variable       ${TS_CASE_LOG_PATH}/script_result_011_${script_name}.zip
    File Should Exist    ${TS_CASE_LOG_PATH}/script_result_011_${script_name}.zip
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${script_unzip_file_path}    Join Path    ${TS_CASE_LOG_PATH}    script_${timestamp}
    extract zip file    ${script_zip_file_path}    ${script_unzip_file_path}
    ${output}   OperatingSystem.get file    ${script_unzip_file_path}/snapshot_file_list.txt
    ${script_log_names}   Get Regexp Matches   ${output}   .*SCRIPT_RESULT.*
    ${script_zip_names}   get_zip_names_by_filter    ${script_unzip_file_path}/snapshot_file_list.txt    SCRIPT_RESULT
    FOR  ${item}  IN  @{script_zip_names}
       extract zip file    ${script_unzip_file_path}/${item}    ${script_unzip_file_path}
    END
    FOR  ${item}  IN  @{script_log_names}
        File Should Exist    ${script_unzip_file_path}/${item.strip()}
        File Should not be empty    ${script_unzip_file_path}/${item.strip()}
    END

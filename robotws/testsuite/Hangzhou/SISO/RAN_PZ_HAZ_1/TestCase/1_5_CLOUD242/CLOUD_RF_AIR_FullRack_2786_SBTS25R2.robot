*** Settings ***
Documentation    Suite description
...    Author:        nick.1.wu@nokia-sbell.com
...    Maintainer:    Wu Nick

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables   ./env.py

Force Tags        CLOUD_RF_AIR_FullRack_2786    CA_GVe    RAN_5G_TDD    RAN_5G    SBTS00
...    STATE_SW_UPLOADED

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{BTS_CLOUD_RF_AIR_FullRack_2786}    HW_ID=BTS_CLOUD_RF_AIR_FullRack_2786    ONAIR_TIME=20 min     site_mode=4G
&{BTS_CLOUD_RF_AIR_FullRack_AZHL}    HW_ID=BTS_CLOUD_RF_AIR_FullRack_AZHL    ONAIR_TIME=20 min     site_mode=4G
&{BTS_CLOUD_RF_AIR_FullRack_10M}     HW_ID=BTS_CLOUD_RF_AIR_FullRack_10M    ONAIR_TIME=20 min     site_mode=4G
&{BTS_CLOUD_RF_AIR_FullRack_CB0012329}     HW_ID=BTS_CLOUD_RF_AIR_FullRack_CB0012329    ONAIR_TIME=20 min    site_mode=4G
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}    BTS_CLOUD_RF_AIR_FullRack_2786

${attachs}     162:164:131:133:150:152:142:144:147:149:138:139:136:137:154:156:159:161
#${required_power_rfs}    EB191060014:YK203400047:1M203225543:6Q173706875
#@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    Unit power reset
#${INIT_CONFIG_ID}    BTS_CLOUD_RF_AIR_FullRack_AZHL
${RFSW_PASSWORD}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
${deltaDict11}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/TestCase/1_5_CLOUD242/Delta_Configuration_scf_MRBTS-2595_1.json'
${deltaDict12}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/TestCase/1_5_CLOUD242/Delta_Configuration_scf_MRBTS-2595_2.json'

*** Test Cases ***
[1][1.0] Common_SiSo_Testabililty_BS-RF__LTE_RTWP online monitoring
    [Tags]    SBTS00:QC_33225    SBTS24R3:QC_847885    SBTS25R2:QC_146643    SBTS24R2:QC_775281
    ...    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=rfDiagnosticTest    config_id=BTS_CLOUD_RF_AIR_FullRack_AZHL
    Automated RF Diagnostic Test
    Antenna Line Online Monitoring check
    Change Testline Configuration    config_id=BTS_CLOUD_RF_AIR_FullRack_10M
    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_Cell block & unblock
    [Tags]    SBTS00:QC_33223    SBTS23R4:QC_627226    SBTS25R2:QC_146640    SBTS24R2:QC_775279
    ...    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block_Unblock
    ...    config_id=BTS_CLOUD_RF_AIR_FullRack_2786
    Cell Block And Unblock All    required_cells=${attachs}
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_RF Lock & Unlock
    [Tags]    SBTS00:QC_33222    SBTS23R4:QC_627225    SBTS25R2:QC_146642    SBTS24R2:QC_775280
    ...    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Ru_Lock_Unlock
    ...    config_id=BTS_CLOUD_RF_AIR_FullRack_2786
    Ru lock And Unlock All    required_cells=${attachs}
    [Teardown]    Testcase Basic Postcondition

[2.0] Common_SiSo_Startup_RF power off then on
    [Tags]    SBTS00:QC_33224   SBTS25R2:QC_146641    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=blackbox
    ...    config_id=BTS_CLOUD_RF_AIR_FullRack_2786
    Create Node Parameters From Current SCF
    SISO_RF module power reset
    Check Fault Signature    faultId=4589    category=POWER_OFF    connection=${CASE_NAME}_${MASTER_BTS_ID}
    [Teardown]    Testcase Basic Postcondition

[1.0] Manual_SiSo_FM_Fail_safe_mode_fault_activation
	[Tags]    SBTS00:QC_33227    SBTS25R2:QC_146645     QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=fail_safe_mode
    ...    config_id=BTS_CLOUD_RF_AIR_FullRack_10M
    Radio_Module_fail_safe_mode_fault_activation    1M203225543
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Manual_SiSo_SM_Radio_unit_remote_reset_during_fail_safe_mode
	[Tags]    SBTS00:QC_33226    SBTS25R2:QC_146644    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=reset_fail_safe_mode
    ...    config_id=BTS_CLOUD_RF_AIR_FullRack_10M
    Radio_Module_fail_safe_mode_fault_activation_reset    1M203225543
    [Teardown]    Testcase Basic Postcondition

[1][1.0]CB012329-B&C_Common SiSo Configuration Management Delta plan Commissioning RAT Addition or Deletion
	[Tags]    SBTS00:QC_65838    SBTS25R2:QC_146610    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=DeltaFile_Recommissioning1
    ...    config_id=BTS_CLOUD_RF_AIR_FullRack_CB0012329
    SiSo DeltaFile Recommissioning Test         ${deltaDict11}
    [Teardown]    Testcase Basic Postcondition

[2][1.0]CB012329-B&C_Common SiSo Configuration Management Delta plan Commissioning RAT Addition or Deletion
	[Tags]    SBTS00:QC_65840    SBTS25R2:QC_146611    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=DeltaFile_Recommissioning2
    ...    config_id=BTS_CLOUD_RF_AIR_FullRack_CB0012329
    SiSo DeltaFile Recommissioning Test         ${deltaDict12}
    [Teardown]    Testcase Basic Postcondition

*** Keywords ***

Radio_Module_fail_safe_mode_fault_activation_reset
    [Arguments]    ${rf_sn}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    ${RRU_Info}    Get RRU Info    serial_num=${rf_sn}
    ${RRU_IP}    Set Variable    ${RRU_Info['parameters']["ipAddress"]}
    ${bts_id}    Get Master BTS Id With RF serial Number     serial_num=${rf_sn}
    ${connection_id}   Set Variable    ${CASE_NAME}_${bts_id}
    ${trigger_command1}    Create List    / action create ResetControl /CI/resetControl/module /module
    ...    /CI/resetControl/module action enable_fail_safe_mode
    ${trigger_command2}    Create List    / action create ResetControl /CI/resetControl/module /module
    ...    /CI/resetControl/module get fail_safe_mode
    ${reboot_command}    Create List    reboot
    ${recovery_command}    Create List    / action create ResetControl /CI/resetControl/module /module
    ...    /CI/resetControl/module action disable_fail_safe_mode
    log to console    ***************** trigger fault *********************
    Send RRU Command in frmonShellClient     ${rf_sn}    ${RRU_IP}    ${trigger_command1}
    Send RRU Command via ssh    ${rf_sn}    ${RRU_IP}    ${reboot_command}
    sleep    60s
    Wait Until Keyword Succeeds    300s    10s    Verify HW State
    Wait Until Keyword Succeeds    300s    10s    coam.assert_alarm_active
    ...    parameters=faultId=2934    connection=${connection_id}
    log to console    ***************** Check Status *********************
    Send RRU Command in frmonShellClient     ${rf_sn}    ${RRU_IP}    ${trigger_command2}
    coam.assert any    class_name=RMOD    parameters=availabilityStatus=regex"(?i)Failed", serialNumber=${rf_sn}
    ...    timeout=60s    alias=${CASE_NAME}_${bts_id}
    coam.assert any    class_name=RMOD    parameters=operationalState=regex"(?i)disabled", serialNumber=${rf_sn}
    ...    timeout=60s    alias=${CASE_NAME}_${bts_id}
    ${result1}    Run Keyword And Return Status    Check Ru Fault History Log
    ...    ${rf_sn}    ${RRU_IP}    ru_fault_id=1462    file_path=/ram/fault_history_log.txt
    ${result2}    Run Keyword And Return Status    Check Ru Fault History Log
    ...    ${rf_sn}    ${RRU_IP}    ru_fault_id=1462    file_path=/ram/fault_history_log_temp.txt
    Should Be True    ${result1} or ${result2}
    log to console    ***************** clear fault *********************
    Send RRU Command in frmonShellClient     ${rf_sn}    ${RRU_IP}    ${recovery_command}
    Radio Reset    ${rf_sn}
    sleep    60s
    Wait Until Keyword Succeeds    300s    10s    Verify HW State
    Wait Until Keyword Succeeds    300s    10s    coam.assert_alarm_inactive
    ...    parameters=faultId=2394    connection=${connection_id}
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Check Alarms
    ${fault4590}    Set Variable    Fault signature for crash or failure
    ${fault2394_related}    Set Variable    Radio Module fail safe mode:SW corrupted:No connection to unit
    Check Historical Alarms    additional_allowed_alarms=${fault2394_related}:${fault4590}
	Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run Keyword And Ignore Error    Run Keywords
    ...    Send RRU Command in frmonShellClient   ${rf_sn}    ${RRU_IP}    ${recovery_command}
    ...    AND    Send RRU Command via ssh    ${rf_sn}    ${RRU_IP}    ${reboot_command}
    ...    AND    Wait For All Cells OnAir    timeout=${ONAIR_TIME}

SiSo DeltaFile Recommissioning Test
    [Arguments]    ${delta_json_path}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        coam.Perform delta recommissioning    ${delta_json_path}    skip_parameter_relation_errors=True
		...    should_activate=true
		...    timeout=600
        ...    connection=${CASE_NAME}_${bts_id}
        Create Node Parameters From Current SCF
    END
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Check Alarms
    Check Historical Alarms
    Make L3call    extra_peak_rate_config=${extra_peak_rate_config}     required_cells=${required_cells}

*** Settings ***
Documentation
...   Test suite for regression testing of feature LTE4862/LTE5735/LTE5692
...   author: Tomasz Krol, Tomasz Reczek
...   contact: tomasz.krol@nokia.com,tomasz.reczek@nokia.com

Library             taf.rfrl.utilities.logger.custom_logger                                 WITH NAME    Logger
Library             ../../../../resources/epcsim/epcsim_operations.py
Library             ../../../../resources/emssim/emssim_operations.py
Library             ../../../../resources/rfc/rfc_operations.py
Library             ../../../../resources/asir/alarm_verification.py
Library             ../../../../resources/ue/ue_verification.py
Library             ./resources/CustomAsirKeywords.py
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource            taf/rfrl/ue/robot/REAL_UE.robot
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables           ./resources/deltas.py

Suite Setup         Common Suite Setup With OnAir Test Line Preparation
...                 swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt

Suite Teardown      Common Suite Teardown

Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Common Postconditions With Watching Alarms


*** Variables ***
# EPCSIM
${s1_allowed_alarm}                 Transport layer connection failure in S1 interface
@{CUSTOM_ALLOWED_ALARMS}            @{EMPTY}
@{CUSTOM_ASIR_ALLOWED_ALARMS}       @{EMPTY}
@{epcsim_cfg_files}                 ${CURDIR}/config/sim_0_ipv4.cfg  ${CURDIR}/config/sim_1_ipv4.cfg

# EMSSIM
${VM_IP}                10.84.175.243
${VM_OAM_IP}            10.255.4.127
${RFC_OAM_IP}           10.84.164.48
${RFC_ID}               76048
${RFC_AUTH}             12345678
${RFC_PRIV}             0123456789
${RFC_SSH_LOGIN}        sshd
${RFC_SSH_PASSWORD}     1qaz2WSX

# Data Transfer
${RFCCELL_ENBID}                        76025
${RFCCELL_EUTRA_CELLID}                 19462401
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${ENABLE_RACH_OBSERVER}                 ${False}
${TPUT_DURATION}                        30s
${TPUT_PROTOCOL}                        udp
${TPUT_DIRECTION}                       dl
${TPUT_VALUE}                           100 Mbits/sec
${TPUT_DEVATION}                        15%


*** Test Cases ***
[1][1.0] LTE4862_3_06_TC26_Multi_MOCN_2cell_from_BBU+LTE_1cell_from_RFC_2_different_operator
    [Setup]     Run Keywords
    ...         Common Preconditions With Watching Alarms
    ...         AND
    ...         gnb_alarm.Allow Alarm  alarm=${s1_allowed_alarm}
    ...         AND
    ...         Perform Delta Commissioning On gNB  delta=${delta_2mme}
    ...         AND
    ...         Setup All EPCSIMs

    Load EPCSIM Configuration File                   epc_id=0
    Load EPCSIM Configuration File                   epc_id=1
    Wait for S1 Up on all EPCSIMs

    [Teardown]  Run Keywords
    ...         Perform Delta Commissioning On gNB  delta=${delta_1mme}
    ...         AND
    ...         Wait For Site To Be Onair
    ...         AND
    ...         Common Postconditions With Watching Alarms
    ...         AND
    ...         gnb_alarm.Disallow Alarm  alarm=${s1_allowed_alarm}

[1][1.0] LTE4862_2_01_Check_EMSSIM_and_RFC_Integration
    [Setup]       Custom EMSsim Test Setup
    Connect to RFC    rfc_ip=${RFC_OAM_IP}    auth=${RFC_AUTH}    priv=${RFC_PRIV}

[1][1.0] LTE4862_2_03_Check_DL_Input_Power_Low_Alarm_01_raised_and_cleared
    [Setup]       Custom EMSsim Test Setup
    Clear EMSSIM Alarm History
    Connect to RFC    rfc_ip=${RFC_OAM_IP}    auth=${RFC_AUTH}    priv=${RFC_PRIV}
    Raise RFC DL Input Power Low Alarm 01
    Sleep  40
    Verify RFC DL Input Power Low Alarm 01 Is Raised on EMSSIM
    Clear EMSSIM Alarm History
    Clear RFC DL Input Power Low Alarm 01
    Sleep  40
    Verify RFC DL Input Power Low Alarm 01 Is Cleared on EMSSIM


[1][1.0] LTE4862_2_05_Check_DL_Input_Power_OverLoad_Alarm_01_raised_and_cleared
    [Setup]       Custom EMSsim Test Setup
    Clear EMSSIM Alarm History
    Connect to RFC    rfc_ip=${RFC_OAM_IP}    auth=${RFC_AUTH}    priv=${RFC_PRIV}
    Raise RFC DL Input Power OverLoad Alarm 01
    Sleep  40
    Verify RFC DL Input Power OverLoad Alarm 01 Is Raised on EMSSIM
    Clear EMSSIM Alarm History
    Clear RFC DL Input Power OverLoad Alarm 01
    Sleep  40
    Verify RFC DL Input Power OverLoad Alarm 01 Is Cleared on EMSSIM

[1][1.0] LTE4862_1_04_TC36_cell_activation_B2_from_BBU_and_B7_from_1st_RFC_and_B66_from_2nd_RFC_new_Ant
   [Documentation]
    ...    Source configuration:
    ...                         - WebEM - main cell configured on B66 band
    ...                         - ASiR WebEM - main cell configured on B66 band and 1 RFC configured on B7 band
    ...     Preparation:
    ...                         - WebEM - main cell change from B66 to B2
    ...                         - ASiR WebEM - main cell change from B66 to B2 and add 2nd RFC configured on B66
    ...     Cleanup:
    ...                         - WebEM - main cell change from B2 to B66
    ...                         - ASiR WebEM - main cell change from B2 to B66 and delte 2nd RFC

    [Setup]  Run Keywords
    ...                     Recommissioning BTS and Asir and wait for onAir
    ...                                                           bts_delta=${delta_b66_b2}
    ...                                                           asir_delta=${delta_add_RFC2_and_change_cell_1_to_b2}
    ...                     AND
    ...                     Common Preconditions With Watching Alarms

    gnb_asir.Wait for ASIR to be OnAir
    Wait Until Keyword Succeeds  2x  10s                     gnb_asir.Verify All Cell Channels are Enabled
    gnblink.Verify Hub BBU CPRI Link State
    gnblink.Verify HUB ANT CPRI Link State
    gnb_asir.Verify Number of RFC                            expected_rfc_number=${2}
    gnb_asir.Verify Number of BTS Cell                       expected_bts_cell_number=${1}
    ${asir_scf_path}    gnb_asir.Get Current SCF File        local_dir_path=${LOG_PATH}
    ...                                                      file_name=asir_sc_after_recommissioning.xml
    gnb_asir.Verify Power Consumption of all Antennas        scf_file_path=${asir_scf_path}
    gnblink.Verify Hub RFC CPRI Link State
    gnb_asir.Verify All RfcCell Channels are Enabled
    gnb_asir.Verify All AntResource under RfcChannel are Enabled
    gnb_asir.Verify Only Allowed Alarms are Active           ${ASIR_ALLOWED_ALARMS}

    [Teardown]  Run Keywords
    ...                     Common Postconditions With Watching Alarms
    ...                     AND
    ...                     Recommissioning BTS and Asir and wait for onAir
    ...                                                           bts_delta=${delta_b2_b66}
    ...                                                           asir_delta=${delta_delete_RFC2_and_delta_cell_1_b66}


[1][1.0] LTE4862_1_02_TC33_UE_call_LTE_B2_1cell_from_BBU_and_B7_1cell_from_RFC_new_Ant
    [Setup]  Run Keywords
    ...                     Recommissioning BTS and Asir and wait for onAir
    ...                                                           bts_delta=${delta_b66_b2}
    ...                                                           asir_delta=${delta_cell_1_b2}
    ...                     AND
    ...                     Common Preconditions With Watching Alarms

    gnb_asir.Verify All RfcCell Channels are Enabled
    gnb_asir.Verify All AntResource under RfcChannel are Enabled

    Prepare Ue for L3 Call
    ue.Attach Ue    UE
    Verify UE is Attached to Proper BTS and Cell    bts_id=${RFCCELL_ENBID}
    ...                                             cell_id=${RFCCELL_EUTRA_CELLID}
    Start Data Transfer and Verify Troughput        direction=${TPUT_DIRECTION}
    ...                                             duration=${TPUT_DURATION}
    ...                                             protocol=${TPUT_PROTOCOL}
    ...                                             tput=${TPUT_VALUE}
    ...                                             deviation=${TPUT_DEVATION}

    [Teardown]  Run Keywords
    ...                     Common Postconditions With Watching Alarms
    ...                     AND
    ...                     Recommissioning BTS and Asir and wait for onAir
    ...                                                           bts_delta=${delta_b2_b66}
    ...                                                           asir_delta=${delta_cell_1_b66}

[1][1.0] LTE5692_CfgMgmt_8_Configuration_Management_RFC_support_create_RFC_objects
    gnb_asir.Perform ASiR Commissioning     ${OUTPUT DIR}/REST_GNB0_ASIR_current_scf.xml
    Sleep  30  reason=Wait for HUB rest after commissioning
    Logger.Log Info To Console      Wait for ASiR enter onAir state
    gnb_asir.Wait For Asir To Be Onair
    Wait Until Keyword Succeeds     10min    1min    gnb_asir.Verify Status Of All ASiR Cells Is Operational

[1][1.0] LTE5692_HW_View_13_Compact_Site_Status_View_RFC
    Verify RFC is Commissioned      rfc_id=${1}

[1][1.0] LTE5735_CfgMgmt_9_Online_Commissioning_Wizard_RFC_Cell_delete
    Logger.Log Info To Console      Removing RFC-1
    gnb_asir.Perform ASiR Recommissioning    ${delta_delete_RFC1}
    Wait Until Keyword Succeeds     30sec    10sec    gnb_asir.Verify Status Of All ASiR Cells Is Operational
    Logger.Log Info To Console      Adding RFC-1
    gnb_asir.Perform ASiR Recommissioning    ${delta_add_RFC1_B7}
    Wait Until Keyword Succeeds     30sec    10sec    gnb_asir.Verify Status Of All ASiR Cells Is Operational


*** Keywords ***
Custom EMSsim Test Setup
    Common Preconditions With Watching Alarms
    Setup EMSsim            host=${VM_IP}
    ...                     oam_ip=${VM_OAM_IP}
    ...                     bts_ip=${RFC_OAM_IP}
    ...                     manager_id=${RFC_ID}
    Connect to RFC via SSH  rfc_ip=${RFC_OAM_IP}
    ...                     rfc_login=${RFC_SSH_LOGIN}
    ...                     rfc_password=${RFC_SSH_PASSWORD}

Setup All Epcsims
    FOR    ${epc_id}  ${cfg_file}  IN ENUMERATE  @{epcsim_cfg_files}
        Stop EPCSIM                                      epc_id=${epc_id}
        Start EPCSIM                                     epc_id=${epc_id}
        Scp EPCSIM Configuration File to Remote Machine  epc_id=${epc_id}
        ...                                              local_cfg_file=${cfg_file}
    END

Recommissioning BTS and Asir and wait for onAir
    [Arguments]    ${bts_delta}    ${asir_delta}
    Perform Delta Commissioning On gNB              delta=${bts_delta}
    gnb_asir.Perform ASIR Recommissioning           delta=${asir_delta}
    Wait Until Keyword Succeeds  5x  20 sec         Verify Setup Of All Cells

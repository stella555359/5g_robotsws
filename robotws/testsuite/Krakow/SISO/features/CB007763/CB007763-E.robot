*** Settings ***
Documentation
...   Keywords for CB007763 feature.
...   author: Jaroslaw Lezon, Damian Silkowski
...   contact: jaroslaw.lezon@nokia.com, damian.silkowski@nokia.com

Library      taf/rfrl/bts/devices/du/combined/observers.py
Library      taf.rfrl.bts.devices.du.commissioning.GnbCommissioning
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations
Library      taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    alarm_verification
Library      taf.ul.sc.perf.util.logger
Library      taf.rfrl.common_resources.python.common_utilities
Library      ./resources/resources.py   WITH NAME    kw
Library      testsuite.Krakow.resources.alarm.Alarm    WITH NAME    alarm
Library      testsuite.Krakow.SISO.resources.ru_map.RuMap    WITH NAME    ru_map
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/bts/robot/common/gnb_scf.robot
Resource     taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     ./resources/res_robot.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       common_setups_and_teardowns.Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        common_setups_and_teardowns.Common Preconditions With Watching Alarms
Test Teardown     common_setups_and_teardowns.Common Postconditions With Watching Alarms

*** Variables ***
${capabilities}    REAL_UE
${duration}    180s
${deviation}     25%
${size_packet}    1400B
${size_packet_dl}    1400B
${size_packet_ul}    1400B
${parallel_streams_ul}    4
${parallel_streams_dl}    4
${interval}    1
${prepare_ue}    True
${reboot_ue}    True
${buffer_client_ul}    4M
${buffer_server_ul}    4M
${buffer_client_dl}    4M
${buffer_server_dl}    4M
${timeout_reboot_ue}    100
${current_config}    None
${deviation_TCP_UL_and_BiDir}    15%
${omit}    60
${alias}    UE
${delete_source_pcap_files}    True
${COLLECT_LOGS_DURING_DATA_TRANSFER}  False
${RF_VENDOR}    RFLIGHT
${RF_MODEL}     NT-4X64NS
${RF_IP}        10.83.176.56
${fault_bts_reset_cause}    BTS Reset Cause
${fault_crl_update}    CRL Update Failure
@{CUSTOM_ALLOWED_ALARMS}    ${fault_bts_reset_cause}  ${fault_crl_update}


*** Test Cases ***
CB007763-C_8_CB007763-C-FULL_ASOE_BB_Cell_Set_CB007763-C_CPRI_FH_SA_CONF_1_2
    [Tags]    CLOUD_5G_CLASSICAL_ANDROID_SA_ASOE_AHPH
    ${ru_map}    ru_map.get_ru_map
    ${cells_setup_for_thpt}    kw.prepare_cells_setup_for_bidir_thpt    ${ru_map}
    log    ${cells_setup_for_thpt}
    REAL_UE.Prepare Ue for L3 Call
    ...  capabilities=${capabilities}
    ...  reboot_ue=${reboot_ue}
    ...  timeout_reboot_ue=${timeout_reboot_ue}
    FOR    ${cell_setup}    IN    @{cells_setup_for_thpt}
        res_robot.Run_Bi_Directional_thpt_to_specific_cell    ${cell_setup}
    END

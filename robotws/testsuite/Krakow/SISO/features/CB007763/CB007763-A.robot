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
Library      testsuite.Krakow.SISO.features.CB007763.resources.resources    WITH NAME    kw
Library      testsuite.Krakow.resources.alarm.Alarm    WITH NAME    alarm
Library      testsuite.Krakow.SISO.resources.ru_map.RuMap    WITH NAME    ru_map
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/bts/robot/common/gnb_scf.robot
Resource     taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/SISO/features/CB007763/resources/res_robot.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_SW_UPLOADED    PY36

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
${exp_cells_onair_number}   16
${exp_cells_onair_number_wa_prb}   8
${RF_VENDOR}    RFLIGHT
${RF_MODEL}     NT-4X64NS
${RF_IP}        10.83.176.56
${fault_conf_error}    BTS configuration error (not enough HW for LCR)
${fault_bts_reset_cause}    BTS Reset Cause
${fault_crl_update}    CRL Update Failure
${fault_cell_blocked}   Cell blocked
@{CUSTOM_ALLOWED_ALARMS}    ${fault_conf_error}  ${fault_bts_reset_cause}  ${fault_crl_update}  ${fault_cell_blocked}


*** Test Cases ***
CB007763-A_1_CB007763-A-Disabling_and_Enabling_PRB_pooling_and_Flexible_CA_mode_during_run-time_WebEM
    [Tags]    CRT    CLOUD_5G_CLASSICAL_ANDROID_SA_ASOE_AHPB_FRIJ
    ${flexibleCAMode_dist_name}    kw.preapre_distname_for_fexCAMod
    gnb_scf.Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=${flexibleCAMode_dist_name}
    ...  param_name=flexibleCAMode
    ...  operation=update
    ...  param_value=BasicCAMode
    ...  timeout=${180}
    gnb_bbu.wait for site to be onair
    Wait Until Keyword Succeeds    120    10    kw.verify_number_of_cells_onair   exp_cells_number=${exp_cells_onair_number_wa_prb}
    alarm_verification.verify_alarm_is_active    fault_name=${fault_conf_error}
    gnb_scf.Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=${flexibleCAMode_dist_name}
    ...  param_name=flexibleCAMode
    ...  operation=update
    ...  param_value=NumberCellAmount
    ...  timeout=${180}
    gnb_bbu.wait for site to be onair
    Wait Until Keyword Succeeds    120    10    kw.verify_number_of_cells_onair   exp_cells_number=${exp_cells_onair_number}
    alarm_verification.verify_alarm_is_not_active    fault_name=${fault_conf_error}

CB007763-A_29_CB007763-A-FULL_ASOE_BB_Cell_Set_CB007763-A_MIX_FH_SA_CONF_1_2
    [Tags]    CLOUD_5G_CLASSICAL_ANDROID_SA_ASOE_AHPB_FRIJ
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

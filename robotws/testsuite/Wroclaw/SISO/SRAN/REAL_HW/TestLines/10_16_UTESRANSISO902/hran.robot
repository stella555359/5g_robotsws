*** Settings ***

Documentation
...  author: mateusz.kawka@nokia.com
...  maintainer: mateusz.kawka@nokia.com

#Resource    ../../Resources/Setup/setup_and_teardown.robot
#Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot
#Resource    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/hran_ta/SiSo_PM_PIMC_Counters.robot
Resource     ../../hran_ta/testsuite/SBTS/test_resources/4G_RRM/Automated_SiSo_CALL_LTE_Data_Transfer.robot
#Resource     ../../hran_ta/testsuite/SBTS/test_resources/BS-RF/SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement.robot
#Resource    ../../hran_ta/resources/ca_4G_RRM_carrier_aggregation.robot
#Resource    ../../hran_ta/testsuite/SBTS/test_resources/BS-RF/BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.robot
#Resource    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/hran_ta/SiSo_PM_Embedded_Power_Meter_Counters.robot
#Resource    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/hran_ta/SiSo_PM_Load_Based_MIMO_Muting_For_EE.robot
Resource    ../../hran_ta/testsuite/SBTS/test_resources/4G_RRM/Automated_SiSo_CALL_LTE_Data_Transfer.robot
Resource    ../../hran_ta/testsuite/SBTS/test_resources/5G_RRM/Automated_SiSo_CALL_NR_Data_Transfer.robot


#Suite Setup       Suite Precondition
#Suite Teardown    Suite Postcondition

*** Variables ***
#${CUSTOM_MPLANE_MODE_PRIMARY_NODE_IP}=    10.42.24.137
#${CUSTOM_MPLANE_MODE_PRIMARY_NODE_IP}=    10.44.137.158
#${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=            None      # possible settings : Failed, Always, None
#${CUSTOM_SWITCH_PERFORM_HW_SETUP}=            False     # to disable hardware reconfiguration ( PDU and Optical part ) set value False
#${SKIP_TRUCK_ROLL}    ${True}
#@{additional_common_fault_list}=
#...  faultId=2403
#...  faultId=6450
#...  faultId=134
#...  faultId=4478
#...  faultId=1868
#...  faultId=10
#...  faultId=1815
#...  faultId=4720
#&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}
#${ENABLE_TRUCK_ROLL_FLAG}    ${False}
#${CHECK_SWCONFIG}  ${False}
#=======================================hran_part=======================================
${COMMISSIONING_PATH}  /home/ute/Downloads/working_scf/GTB_migration_onair_SISO902.xml
${HW_LOCATION_CODE}         Wroclaw
${COLLECT_SNAPSHOT_FLAG}    failed_verdict
${TESTLINE_NAME}            10_16_UTESRANSISO902
${CELLS_YAML_PATH}  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestLines/10_16_UTESRANSISO902/cells_dev902.yaml
${ENABLE_TRUCK_ROLL_FLAG}    ${False}


*** Test Cases ***
Automated_SiSo_CALL_LTE_Data_Transfer
    [Setup]    Run Keywords    Set Test Variable    ${CELLS_YAML_PATH}
    ...    AND    Set Test Variable    @{SELECTED_CELLS}    334086
    ...    AND    Automated_SiSo_CALL_LTE_Data_Transfer.TC Setup
    ...    AND    Set Library Search Order  admin  Automated_SiSo_CALL_LTE_Data_Transfer
    [Timeout]    21600
    TC__Automated_SiSo_CALL_LTE_Data_Transfer
    [Teardown]  Automated_SiSo_CALL_LTE_Data_Transfer.TC Teardown

#Automated_SiSo_CALL_NR_Data_Transfer
#    [Setup]    Run Keywords    Set Test Variable    ${CELLS_YAML_PATH}
#    ...    AND    Set Test Variable    @{SELECTED_CELLS}    21381320
#    ...    AND    Automated_SiSo_CALL_NR_Data_Transfer.TC Setup
#    ...    AND    Set Library Search Order  admin  Automated_SiSo_CALL_NR_Data_Transfer
#    [Timeout]    21600
#    TC__Automated_SiSo_CALL_NR_Data_Transfer
#    [Teardown]  Automated_SiSo_CALL_NR_Data_Transfer.TC Teardown

#[1][1.0] Automated_SiSo_PM_Energy_Efficiency_Monitoring_Real_Time_Measurements_During_RU_Block_Unblock
#    [Setup]    Run Keywords    Set Test Variable    ${RMOD_SN}    AH242307925
#    ...    AND    Set Test Variable    ${RMODS}    1
#    ...    AND    Set Test Variable    ${TIME_TO_WAIT}    3
#    ...    AND    Set Test Variable    ${PATH_TO_DOWNLOAD_CSV}    /home/ute/Downloads
#    ...    AND    BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated
#    [Timeout]    14400
#    TC__BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated
#    [Teardown]    Run Keywords     BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.TC Teardown
#	...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action
#
#[1][4.0] Automated_SiSo_PM_Embedded_Power_Meter_Counters
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=live
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    Execute Test In Loop  TC__SiSo_PM_Embedded_Power_Meter_Counters
#    [Teardown]  Configuration Postcondition

#[1][1.0] Automated_SiSo_PM_Energy_Efficiency_Monitoring_Act_Deact_SBTS_Counters_And_Power_Voltage_Measurements
#    [Setup]    Run Keywords    Set Test Variable    ${RMODS}    1
#    ...    AND    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.TC Setup
#    ...    AND    Set Library Search Order    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
#    [Timeout]    14400
#    TC__BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
#    [Teardown]    Run Keywords     BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.TC Teardown
#	...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action

#[1][2.0] Automated_SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement
#    [Setup]  Run Keywords  Set Test Variable  ${COMMISSIONING_PATH}
#    ...  AND  Set Test Variable  ${RMOD_SN}   AH242307925
#    ...  AND  SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement.TC Setup
#    ...  AND  Set Library Search Order    SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement
#    [Timeout]  14400
#    TC__SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement
#    [Teardown]  SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement.TC Teardown

#[CB008392 - MIMO Muting-1][1.0] Automated_SiSo_PM_Load_Based_MIMO_Muting_For_EE
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=live
#    ...  AND  Set Test Variable  ${CELL_ID}  200
#    ...  AND  Set Test Variable  ${node}  ${cfg.active_bts_list}[0]
#    Execute Test In Loop  TC__SiSo_PM_Load_Based_MIMO_Muting_For_EE
#    [Teardown]  Configuration Postcondition

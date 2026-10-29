*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS24R1  SRAN  CLOUD_SRAN_NLWG_1708_2ASIM_1ABIA_2ABIO_2ABIP_1ABIN_2AHCA_2AHMPDA_2FXDB_1AZNA_1AENB_1AZQS
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__FSP_Lom_Fault_Service_crash.robot
Resource    ../../FM/test_resources/FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed.robot
Resource    ../../FM/test_resources/FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.robot
Resource    ../../FM/test_resources/FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_counter_exceeded_FID1907.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_fault_signature_check.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_FID4590.robot
Resource    ../../FM/test_resources/FM__LTE_L2_MACPS_sw_critical_failure.robot
Resource    ../../FM/test_resources/FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.robot
Resource    ../../FM/test_resources/FM__LTE_cell_degraded_when_1_RU_power_off.robot
Resource    ../../FM/test_resources/FM__NR_cell_degraded_when_1_RU_power_off.robot
Resource    ../../FM/test_resources/FM__FSP_common_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__Site_reset_escalation_to_BTS_power_reset.robot
Resource    ../../FM/test_resources/FM__Robustness_trigger_different_faults_RMOD.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
@{GSMVlan}            ${261}  ${262}
${WCDMAVlan}          ${464}
${LTEVlan}            ${461}
${Switch_IP}          10.255.10.109
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       5
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1708


*** Test Cases ***
[1]FM__Site_rst_escalation_to_BTS_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_SN}    	L1220405753
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIN
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    240
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    240
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID_FIRST}    2078
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID_SECOND}    69
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_FIRST}    Baseband card autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}   Baseband card power autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_THIRD}    BTS secondary core autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_FORTH}    BTS site autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_FIFTH}    BTS power autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}          BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}                     Warning

    ...    AND    FM__Site_reset_escalation_to_BTS_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_escalation_to_BTS_power_reset
    TC__FM__Site_reset_escalation_to_BTS_power_reset
    [Teardown]    Run Keywords    FM__Site_reset_escalation_to_BTS_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIP
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIP
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    
    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIO
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO

    ...    AND    FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed.TC Setup
    ...    AND    Modify Resource Search Order    FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed
    TC__FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed
    [Teardown]    Run Keywords    FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9000
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    LTE
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044041600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044001600 64 1

    ...    AND    FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9000
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    LTE
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044181600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044981600 64 1
    ...    AND    FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIP
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9000
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044281600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044981600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RMOD_reset_counter_exceeded_FID1907
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    400
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQS
    ...    AND    Set Test Variable    ${RMOD_MASTER_AMBER}     
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    1907
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Radio autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}    TX out of order
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID_SECOND}    7116
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME_SECOND}    BASE STATION SERVICE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY_SECOND}    Critical
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}     gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY= 
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}     5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=  
    ...    AND    FM__RMOD_reset_counter_exceeded_FID1907.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_reset_counter_exceeded_FID1907
    FM__RMOD_reset_counter_exceeded_FID1907
    [Teardown]    Run Keywords    FM__RMOD_reset_counter_exceeded_FID1907.TC Teardown
    ...    AND    Restore Resource Search Order



[1]FM_RMOD_power_off_on_FID4589
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AZQS
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360

    ...    AND    FM__RMOD_crash_fault_signature_check.TC setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_fault_signature_check
    FM__RMOD_crash_fault_signature_check
    [Teardown]    Run Keywords    FM__RMOD_crash_fault_signature_check.TC Teardown
    ...    AND    Restore Resource Search Order



[1]FM_RMOD_crash_FID4590
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_MASTER_AMBER}    AENB
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}       4590
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Fault signature for crash or failure
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}      7115  
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION INFORMATION
    ...    AND    Set Test Variable    ${SEVERITY}               Warning 
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600

    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__LTE_L2_MACPS_critical_failure
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MODULE_TYPE}    ABIO
    ...    AND    Set Test Variable    ${RAT}    LNCEL
    ...    AND    Set Test Variable    ${TECHNOLOGY}    FDD
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    180
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}      4383
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Internal BTS processes autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}      7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}               Warning 
    ...    AND    FM__LTE_L2_MACPS_sw_critical_failure.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_L2_MACPS_sw_critical_failure
    FM__LTE_L2_MACPS_sw_critical_failure
    [Teardown]    Run Keywords    FM__LTE_L2_MACPS_sw_critical_failure.TC Teardown
    ...    AND    Restore Resource Search Order



[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MODULE_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CELLS_FAILED_TIMEOUT}    180
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}           180

    ...    AND    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Setup
    ...    AND    Modify Resource Search Order    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    TC__FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Teardown]    Run Keywords    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Teardown
    ...    AND    Restore Resource Search Order



[1]FM__LTE_cell_degraded_when_1_RU_power_off
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    900
    ...    AND    Set Test Variable    ${TECHNOLOGY}    LNCEL
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}             10
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID_SECOND}      4003
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}           No connection to unit
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}    Transmission path failure 
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}             7116
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID_SECOND}      7115
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}           BASE STATION SERVICE PROBLEM
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME_SECOND}    BASE STATION INFORMATION 
    ...    AND    Set Test Variable    ${SEVERITY}                      Minor

    ...    AND    FM__LTE_cell_degraded_when_1_RU_power_off.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_cell_degraded_when_1_RU_power_off
    FM__LTE_cell_degraded_when_1_RU_power_off
    [Teardown]    Run Keywords    FM__LTE_cell_degraded_when_1_RU_power_off.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__NR_cell_degraded_when_1_RU_power_off
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${TECHNOLOGY}    NRCEL
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    10
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    No connection to unit
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7116
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION SERVICE PROBLEM

    ...    AND    FM__NR_cell_degraded_when_1_RU_power_off.TC Setup
    ...    AND    Modify Resource Search Order    FM__NR_cell_degraded_when_1_RU_power_off
    FM__NR_cell_degraded_when_1_RU_power_off
    [Teardown]    Run Keywords    FM__NR_cell_degraded_when_1_RU_power_off.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__FSP_common_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    120
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    60
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}            2078
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}            7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID_SECOND}     7100
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}          Baseband card autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}   Baseband card power autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_THIRD}    Eeprom read error
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}          BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME_SECOND}   BASE STATION HARDWARE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY_1}                   Warning
    ...    AND    Set Test Variable    ${SEVERITY_2}                   Critical
    ...    AND    FM__FSP_common_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_common_reset_counter_exceeded
    TC__FM__FSP_common_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__FSP_common_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order

[2]FM__FSP_common_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIP
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    120
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    60
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}            2078
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}            7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID_SECOND}     7100
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}          Baseband card autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}   Baseband card power autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_THIRD}    Eeprom read error
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}          BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME_SECOND}   BASE STATION HARDWARE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY_1}                   Warning
    ...    AND    Set Test Variable    ${SEVERITY_2}                   Critical
    ...    AND    FM__FSP_common_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_common_reset_counter_exceeded
    TC__FM__FSP_common_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__FSP_common_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[3]FM__FSP_common_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIQ	
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    120
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    60
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}            2078
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}            7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID_SECOND}     7100
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}          Baseband card autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}   Baseband card power autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_THIRD}    Eeprom read error
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}          BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME_SECOND}   BASE STATION HARDWARE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY_1}                   Warning
    ...    AND    Set Test Variable    ${SEVERITY_2}                   Critical
    ...    AND    FM__FSP_common_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_common_reset_counter_exceeded
    TC__FM__FSP_common_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__FSP_common_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Robustness_trigger_different_faults_RMOD
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}             10m
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}             30m
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}           10m
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}         10m
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}               180
    ...    AND    Set Test Variable    ${FAULT_ID_1904}               1904
    ...    AND    Set Test Variable    ${FAULT_ID_1905}               1905
    ...    AND    Set Test Variable    ${FAULT_ID_1956}               1956
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}         Radio autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}           7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}         BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}                    Warning
    ...    AND    Set Test Variable    ${FAULT_ID_1955}               1955
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_1955}    Increased BER detected on the optical connection to Radio Module
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID_1955}      7116
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME_1955}    BASE STATION SERVICE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY_1955}               Major

    ...    AND    FM__Robustness_trigger_different_faults_RMOD.TC Setup
    ...    AND    Modify Resource Search Order    FM__Robustness_trigger_different_faults_RMOD
    TC__FM__Robustness_trigger_different_faults_RMOD
    [Teardown]    Run Keywords    FM__Robustness_trigger_different_faults_RMOD.TC Teardown
    ...    AND    Restore Resource Search Order

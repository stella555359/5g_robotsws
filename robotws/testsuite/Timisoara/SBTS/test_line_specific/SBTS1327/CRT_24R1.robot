*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS24R1  SRAN  CLOUD_SRAN_NLWG_1327_1ASIL_2ABIO_1ABIA_1AZQJ_1FXDB_1AEHC STATE_SKIP_AGENT
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__RMOD_reset_counter_exceeded_FID1900.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_FID1981.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_counter_exceeded_FID1907.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_counter_exceeded_FID1901.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_fault_signature_check.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_FID4590.robot
Resource    ../../FM/test_resources/FM__Primary_core_power_off_on.robot
Resource    ../../FM/test_resources/FM__L1_SoC_reset_CB005832_CB007442_interaction.robot
Resource    ../../FM/test_resources/FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.robot
Resource    ../../FM/test_resources/FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__Site_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__RF_hot_remove_hot_insert_via_SWN_RU.robot
Resource    ../../FM/test_resources/FM__LTE_CCplane_crash_RAT_recovery_reset.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
@{GSMVlan}            ${251}  ${252}
${WCDMAVlan}          ${454}
${LTEVlan}            ${451}
${Switch_IP}          10.255.10.118
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       9
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1327


*** Test Cases ***
[1]FM_RMOD_reset_counter_exceeded_FID1900
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{RMOD_TYPE}    AEQE  AENB  AZQJ
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    660
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    900
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    120
    ...    AND    Set Test Variable    @{parameter_values_1}    8
    ...    AND    Set Test Variable    @{parameter_values_2}    8
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    1900
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Radio autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}    RF Module configuring failed
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID_SECOND}    7116
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME_SECOND}    BASE STATION SERVICE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
    ...    AND    Set Test Variable    ${SEVERITY_SECOND}    Critical
    ...    AND    Set Test Variable    ${CATEGORY}    OAM_RESET
    ...    AND    Set Test Variable    ${SCOPE}    RFM

    ...    AND    FM__RMOD_reset_counter_exceeded_FID1900.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_reset_counter_exceeded_FID1900
    TC__FM__RMOD_reset_counter_exceeded_FID1900
    [Teardown]    Run Keywords    FM__RMOD_reset_counter_exceeded_FID1900.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RMOD_reset_counter_exceeded_FID1981
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQJ
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    1981
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Radio autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}    FR module reset requested
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID_SECOND}    7116
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME_SECOND}    BASE STATION SERVICE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY_SECOND}    Critical
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${RMOD_TIMEOUT}    900
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600

    ...    AND    FM__RMOD_reset_FID1981.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_reset_FID1981
    TC__FM__RMOD_reset_FID1981
    [Teardown]    Run Keywords    FM__RMOD_reset_FID1981.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RMOD_reset_counter_exceeded_FID1907
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQJ
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
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=

    ...    AND    FM__RMOD_reset_counter_exceeded_FID1907.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_reset_counter_exceeded_FID1907
    FM__RMOD_reset_counter_exceeded_FID1907
    [Teardown]    Run Keywords    FM__RMOD_reset_counter_exceeded_FID1907.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RMOD_reset_counter_exceeded_FID1901
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    1M221226682
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    660
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    120
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    1901
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Radio autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}    RF Module critical file not found
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID_SECOND}    7111
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME_SECOND}    BASE STATION SOFTWARE MANAGEMENT PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
    ...    AND    Set Test Variable    ${SEVERITY_SECOND}    Critical
    ...    AND    Set Test Variable    ${CATEGORY}    SW_FAILURE
    ...    AND    Set Test Variable    ${SCOPE}    RFM
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=

    ...    AND    FM__RMOD_reset_counter_exceeded_FID1901.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_reset_counter_exceeded_FID1901
    TC__FM__RMOD_reset_counter_exceeded_FID1901
    [Teardown]    Run Keywords    FM__RMOD_reset_counter_exceeded_FID1901.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_power_off_on_FID4589
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AZQJ
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    4589
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Unit power reset
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7115
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION INFORMATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
    ...    AND    Set Test Variable    ${SUPPL_ALARM_INFO}    RU connection was lost in runtime

    ...    AND    FM__RMOD_crash_fault_signature_check.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_fault_signature_check
    FM__RMOD_crash_fault_signature_check
    [Teardown]    Run Keywords    FM__RMOD_crash_fault_signature_check.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQJ
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_SCORPIO}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ...    AND    Set Test Variable    ${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}         4590
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}       Fault signature for crash or failure
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}         7115
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}       BASE STATION INFORMATION
    ...    AND    Set Test Variable    ${SEVERITY}                  Warning
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
	
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Primary_core_power_off_on_fault_signature
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    120
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID_FIRST}    4590
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID_SECOND}    4592
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_FIRST}    Fault signature for crash or failure
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}    BTS Reset Cause
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7115
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION INFORMATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
    ...    AND    Set Test Variable    ${EXPECTED_SCOPE}    Site
    ...    AND    Set Test Variable    ${EXPECTED_CATEGORY_1}    POWER_OFF
    ...    AND    Set Test Variable    ${EXPECTED_CATEGORY_2}    POWER_OFF
    ...    AND    Set Test Variable    ${EXPECTED_INFO_1}    Unknown power reset. Possible causes e.g. HW watchdog or external power off/on cycle
    ...    AND    Set Test Variable    ${EXPECTED_INFO_2}    Power off/on reset

    ...    AND    FM__Primary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Primary_core_power_off_on
    TC__FM__Primary_core_power_off_on
    [Teardown]    Run Keywords    FM__Primary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__L1_SoC_to_FSP_reset_CB005832_CB007442_interaction
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300

    ...    AND    FM__L1_SoC_reset_CB005832_CB007442_interaction.TC Setup
    ...    AND    Modify Resource Search Order    FM__L1_SoC_reset_CB005832_CB007442_interaction
    TC__FM__L1_SoC_reset_CB005832_CB007442_interaction
    [Teardown]    Run Keywords    FM__L1_SoC_reset_CB005832_CB007442_interaction.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELLS_FAILED_TIMEOUT}    180
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    600
    ...    AND    Set Test Variable    ${MODULE_TYPE}    ABIO
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    180
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    4383
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Internal BTS processes autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_RAT_RESET}    RAT autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning

    ...    AND    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Setup
    ...    AND    Modify Resource Search Order    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    TC__FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Teardown]    Run Keywords    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9000
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E0441C1600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044E01600 64 1

    ...    AND    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__Site_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    120
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
	
    ...    AND    FM__Site_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_counter_exceeded
    TC__FM__Site_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__Site_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__RMOD_hot_remove_hot_insert
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RU_SWITCH_IP}    10.255.10.235    # Mandatory. Radio unit serving switch IP.
    ...    AND    Set Test Variable    ${RU_SWITCH_USER}    cli    # Mandatory. Radio unit serving log in credentials.
    ...    AND    Set Test Variable    ${RU_SWITCH_PASSWORD}    Admin@1830    # Mandatory. Radio unit serving log in credentials.
    ...    AND    Set Test Variable    ${RU_SWITCH_INTERFACE}    t24ps1    # Mandatory. Radio unit serving switch interface.
    ...    AND    Set Test Variable    ${RU_SWITCH_SHELF}    1    # Mandatory. Radio unit serving switch shelf id.
    ...    AND    Set Test Variable    ${RU_SWITCH_SLOT}    3    # Mandatory. Radio unit serving switch slot id.
    ...    AND    Set Test Variable    ${RU_SWITCH_PORT}    C1    # Mandatory. Radio unit serving switch port id.
    ...    AND    Set Test Variable    ${RMOD_SN}    L1211409570    # Mandatory. Radio module serial number to be disconnected.
    ...    AND    Set Test Variable    ${PING_RMOD_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RMOD_INSERT_TIMEOUT}    300
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    10
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    No connection to unit
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7116
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION SERVICE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY1}    Major
    ...    AND    Set Test Variable    ${SEVERITY2}    Critical
    ...    AND    Set Test Variable    ${SUPPL_ALARM_INFO}    RU connection was lost in runtime
    ...    AND    Set Test Variable    ${CHECK_NA_ALARM}    True

    ...    AND    FM__RF_hot_remove_hot_insert_via_SWN_RU.TC Setup
    ...    AND    Modify Resource Search Order    FM__RF_hot_remove_hot_insert_via_SWN_RU
    TC__FM__RF_hot_remove_hot_insert_via_SWN_RU
    [Teardown]    Run Keywords    FM__RF_hot_remove_hot_insert_via_SWN_RU.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__LTE_CCplane_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    500

    ...    AND    FM__LTE_CCplane_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_CCplane_crash_RAT_recovery_reset
    TC__FM__LTE_CCplane_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__LTE_CCplane_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order

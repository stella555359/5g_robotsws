*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS24R3  SRAN
...  CLOUD_SRAN_NLWG_1327_1ASIL_1ABIO_1ABIA_1ASIM_1ABIP_1ABIO_1AZQU_1FXDB_1AEHC_1AHFIB_1AHEGA_1AQQJ_1AVQE STATE_SKIP_AGENT
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__RMOD_crash_FID4590.robot
Resource    ../../FM/test_resources/FM__L1_SoC_reset_CB005832_CB007442_interaction.robot
Resource    ../../FM/test_resources/FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.robot
Resource    ../../FM/test_resources/FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_counter_exceeded_FID1907.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_counter_exceeded_FID1901.robot
Resource    ../../FM/test_resources/FM__FID49_Cellblocked_toggling.robot
Resource    ../../FM/test_resources/FM__Primary_core_power_off_on.robot

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
[1]FM_RMOD_crash_FID4590
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
    ...    AND    Set Test Variable    ${RMOD}    AZQU
	
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__L1_SoC_to_FSP_reset_CB005832_CB007442_interaction
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

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

    ...    AND    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RMOD_reset_counter_exceeded_FID1907
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RMOD_SCORPIO}    AZQU
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
    ...    AND    Set Test Variable    ${RMOD_SN}    1M222314684
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
	

[1]FM__FID49_Cellblocked_toggling
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__FID49_Cellblocked_toggling.TC Setup
    ...    AND    Modify Resource Search Order    FM__FID49_Cellblocked_toggling
    TC__FM__FID49_Cellblocked_toggling
    [Teardown]    Run Keywords    FM__FID49_Cellblocked_toggling.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Primary_core_power_off_on_fault_signature
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__Primary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Primary_core_power_off_on
    TC__FM__Primary_core_power_off_on
    [Teardown]    Run Keywords    FM__Primary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order

*** Settings ***
Documentation    SBTS 10489
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS24R2  SRAN  CLOUD_SRAN_NLWG_1489_2ASIB_2ABIA_1ABIO_1ABIN_2FXCB_1AHDB_1AHHB_1AHFIB STATE_SKIP_AGENT
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
@{GSMVlan}            ${251}  ${252}
${WCDMAVlan}          ${351}
${LTEVlan}            ${451}
${Switch_IP}          10.255.6.18
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       9
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1489


*** Test Cases ***
[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_2
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_3
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_4
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_5
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_6
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_7
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_8
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_9
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_10
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_11
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_12
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_13
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_14
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_15
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_16
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_17
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_18
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_19
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_20
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_21
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_22
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_23
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_24
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_25
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_26
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_27
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_28
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_29
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure_30
    [Tags]  QC_270321
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order

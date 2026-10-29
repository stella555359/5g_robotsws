*** Settings ***
Documentation
...  DESCRIPTION:
...             This test use UTE machine CLOUD_5G_I_LO_AP_LO with VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CB009568 RedCap Support in FR1 TDD check L2ET side for redcap ue introduction
...             This test use UTE Golden configuration
...
...  AUTHOR:    riyad.ferrag@nokia.com
...           \n2024-04-23    - vincent.boulet@nokia.com    - Parity testing to introduce dRNIC RINLINE2 CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC


Resource           resources/robot/CB009568_SR_B_keywords.robot


Suite Setup        Suite Setup From Scratch
...                keepAllUeDataInCfgFile=${True}
...                automaticTeardown=FirstFail

Suite Teardown     9568_Test Suite Teardown
Test Teardown      9568_Test Teardown

*** Variables ***

${AutoSaveDebugData}    ${False}
${target_dir}           None
${VMmonitoring}         ${False}
${debugArg}             ${True}

${userneed_PCAP}        ${False}
${userneed_TTI}         ${False}
${userneed_Btslog}      ${False}
${save_debug_data}      ${False}
${userneed_TPcheck}     ${False}
${userneed_PM}          ${False}


${A_14_EI8_IWK}         ${False}
${A_12_EI7_CL}          ${False}
${A_13_EI7_OL}          ${False}

${B3_EI3_TC1}           ${False}
${B4_EI4_TC2}           ${False}
${B3_EI5_TC4}           ${True}

${Delta_scf_dlDmrsType2}          ${CURDIR}/resources/config/Delta_SCF_CB009568_dlDmrsType2.json

*** Test Cases ***

[1]CB009568-EI5_TC4_RedCap_UE_with_dlDmrsType2
    [Tags]    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...              The purpose of the test is to validate the number of CDM group without Data
    ...              when actDlDataDmrsFdm set to true and mcs higher than dlDataDmrsFdmThres64QamMcs
    ...              or dlDataDmrsFdmThres256QamMcs for RedCap UEs and DMRS Type2 configuration.
    ...
    ...  PRECONDITIONS:
    ...              CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    ...              test line is well set and operational for L3 call of normal UE
    ...
    ...  TESTING TOOLS:
    ...              AirPhone, WebEM
    ...
    ...  TEST ENVIRONMENT:
    ...             HARDWARE ID:   AEQE
    ...
    ...  REQUIRED LOGS:
    ...             Snapshot, RD.BTS log,
    ...             Cprt logs just after cell_setup for SIB1 Analysis
    ...             bip L1L2 time of UE redcap attach (register/pdusession) to check LCID and PDCP-SN size
    ...             TTI on traffic, PM legacy and 9568 from traffic up to CQI downgrade collection end
    ...
    ...  REFERENCES:           CB009568_A CFAM

    [Setup]    Run Keywords
    ...                      9568_Init Trace color
    ...    AND               9568_Create Test Suite Folder
    ...    AND               9568_Capture_session_initiating
    ${AutoSaveDebugData}     Set Variable  ${True}
    Set Global Variable      ${AutoSaveDebugData}

    ${userneed_PCAP}       Set Variable        ${True}
    ${userneed_TTI}        Set Variable        ${True}
    ${userneed_Btslog}     Set Variable        ${False}
    ${save_debug_data}     Set Variable        ${True}
    ${userneed_TPcheck}    Set Variable        ${False}
    ${userneed_PM}         Set Variable        ${False}

    Set Global Variable    ${userneed_PCAP}
    Set Global Variable    ${userneed_TTI}
    Set Global Variable    ${userneed_Btslog}
    Set Global Variable    ${save_debug_data}
    Set Global Variable    ${userneed_TPcheck}
    Set Global Variable    ${userneed_PM}

    ${FirstTime}           Set Variable     ${True}
    Set Global Variable    ${FirstTime}

    CB009568 Main Scenario      ${A3}      ${Delta_scf_dlDmrsType2}

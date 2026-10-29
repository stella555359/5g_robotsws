*** Settings ***
Documentation
...  DESCRIPTION:
...             This test use UTE machine CLOUD_5G_O_H_AP_LOO with VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
...             CB009568 RedCap Support in FR1 TDD check L2ET side for redcap ue introduction
...             This test use UTE Golden configuration
...
...  AUTHOR:        riyad.ferrag@nokia.com
...  ASOH PARITY:   marie-laurence.le_borgne@nokia.com and martial.hummel@nokia.com

Resource           resources/robot/CB009568_SR_B_keywords.robot


Suite Setup        Suite Setup From Scratch
...                keepAllUeDataInCfgFile=${True}
...                automaticTeardown=FirstFail
...                iphyPathname=${CURDIR}/resources/config/iphy_CB009568_B4_EI4_TC2_ulMuMimo_ASOH.xml

Suite Teardown     9568_Test Suite Teardown
Test Teardown      9568_Test Teardown

*** Variables ***

${AutoSaveDebugData}            ${False}
${target_dir}                   None
${VMmonitoring}                 ${False}
${debugArg}                     ${True}

# Preinit for "Bouchon" cases - don't modify the value here but on keyword file
${userneed_PCAP}                ${False}
${userneed_TTI}                 ${False}
${userneed_Btslog}              ${False}
${save_debug_data}              ${False}
${userneed_TPcheck}             ${False}
${userneed_PM}                  ${False}

${A_14_EI8_IWK}                 ${False}
${A_12_EI7_CL}                  ${False}
${A_13_EI7_OL}                  ${False}

${B3_EI3_TC1}                   ${False}
${B3_EI5_TC4}                   ${False}
${B4_EI4_TC2}                   ${True}


${Delta_SCF_ulMuMimo}           ${CURDIR}/resources/config/Delta_SCF_CB009568_ulMuMimo_ASOH.json

*** Test Cases ***

[1]CB009568-B4_EI4_TC2_RedCap_UE_with_UL_MU-MIMO_ASOH
    [Tags]    CLOUD_5G_O_H_AP_LOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...              The purpose of this TC is to verify UL pairing for 2 UEs with rank 1 or 2
    ...
    ...  PRECONDITIONS:
    ...              CLOUD_5G_O_H_AP_LOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD 
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
    ...  REFERENCES:           CB009568-B CFAM

    [Setup]    Run Keywords
    ...                      9568_Init Trace color
    ...    AND               9568_Create Test Suite Folder
    ...    AND               9568_Capture_session_initiating
    ${AutoSaveDebugData}     Set Variable  ${True}
    Set Global Variable      ${AutoSaveDebugData}

    #Need for this test

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

    ${FirstTime}           Set Variable        ${True}
    Set Global Variable    ${FirstTime}
    
    CB009568 Main Scenario      ${A2}          ${Delta_SCF_ulMuMimo}


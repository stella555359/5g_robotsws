*** Settings ***
Documentation
...  DESCRIPTION:
...             This test use UTE machine CLOUD_5G_I_MP_AP_LO with VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...             to test CB012979 : Enabler for UP and CP performance
...             Optimization ID99 is considered and is the object of this automation.
...
...  AUTHOR:    riyad.ferrag@nokia.com

Resource           resources/robot/CB012979_keywords.robot

Suite Setup        Suite Setup From Scratch
...                keepAllUeDataInCfgFile=${True}
...                automaticTeardown=FirstFail

Suite Teardown     12979_Test Suite Teardown
Test Teardown      12979_Test Teardown

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

# To be deleted ------------------------------
${A_14_EI8_IWK}                 ${False}
${A_13_EI7_OL}                  ${False}

${B3_EI3_TC1}                   ${True}
${B3_EI5_TC4}                   ${False}
${B4_EI4_TC2}                   ${False}
#---------------------------------------------

${Delta_SCF}                    ${CURDIR}/resources/config/Delta_SCF_CB012979.json

*** Test Cases ***

[1]CB012979-H_ID99_TC2_PDSCH_with_64KB_BIP_payload_ASOH
    [Tags]    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...              The purpose of this TC is to verify CB012979-G ID99 Optimization
    ...
    ...  PRECONDITIONS:
    ...              CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
    ...              test line is well set and operational for L3 call of normal UE
    ...
    ...  TESTING TOOLS:
    ...              AirPhone, WebEM
    ...
    ...  TEST ENVIRONMENT:
    ...              HARDWARE ID: AEQE
    ...
    ...  REQUIRED LOGS:
    ...              Snapshot, bip L1L2, TTI trace
    ...
    ...  REFERENCES: CB012979-H CFAM

    [Setup]    Run Keywords
    ...                      12979_Init Trace color
    ...    AND               12979_Create Test Suite Folder
    ...    AND               12979_Capture_session_initiating
    ${AutoSaveDebugData}     Set Variable  ${false}
    Set Global Variable      ${AutoSaveDebugData}

    #Need for this test

    ${userneed_PCAP}       Set Variable        ${true}
    ${userneed_TTI}        Set Variable        ${true}
    ${userneed_Btslog}     Set Variable        ${false}
    ${save_debug_data}     Set Variable        ${false}
    ${userneed_TPcheck}    Set Variable        ${false}
    ${userneed_PM}         Set Variable        ${false}

    Set Global Variable    ${userneed_PCAP}
    Set Global Variable    ${userneed_TTI}
    Set Global Variable    ${userneed_Btslog}
    Set Global Variable    ${save_debug_data}
    Set Global Variable    ${userneed_TPcheck}
    Set Global Variable    ${userneed_PM}

    ${FirstTime}           Set Variable        ${true}
    Set Global Variable    ${FirstTime}

    CB012979 Main Scenario      ${A1}          ${Delta_SCF}

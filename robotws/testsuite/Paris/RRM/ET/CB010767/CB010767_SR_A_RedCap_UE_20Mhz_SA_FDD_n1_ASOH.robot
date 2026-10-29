*** Settings ***
Documentation
...  DESCRIPTION:
...  this test use UTE machine CLOUD_5G_O_H_AP_LOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
...
...             CB010767_RedCap_Support_in_FR1_FDD  check L2ET side for redcap ue introduction
...             plus 5mhz construction with custom_config. On this base, redcap configuration is set directly by the test script
...
...             author:                 francois.tourlonnias@nokia.com
...             modified by marie-laurence.le_borgne@nokia.com and martial.hummel@nokia.com for ASOH Parity
...

Resource           resources/robot/CB010767_SR_A_RedCap_UE_20Mhz_SA_FDD_n1_keywords.robot


Suite Setup        Suite Setup From Scratch
...                keepAllUeDataInCfgFile=${True}    #set in comment for robustness cfg file to 200 ue
...                automaticTeardown=FirstFail
...                yamlPathname=${CURDIR}/../../../../../custom-config/${feature path}${custom_config_file_ASOH}


# Suite Teardown     10767_Test Suite Teardown for CB010767_SR_A  # If commented, we not restore the TL as original config. It stay like end of test
Test Teardown      10767_Test Teardown CB010767_SR_A

*** Variables ***
${feature path}                          ReductCapa/5GC010767/
${custom_config_file_ASOH}               custom_config_10767_rc_ASOH.yaml

# variable set to ${True} to automatically save SOS report and OAM snapshot
# (by default, these information are saved only if a test is failed)
${AutoSaveDebugData}    ${False}
${target_dir}           None
${VMmonitoring}         ${False}  #will create a MONITORING directory, collect Top info each 20s and do a preprocessing of data
${debugArg}             ${True}  #${True}  True is used to see more details on console

# Preinit for "Bouchon" cases - don't modify the value here but on keyword file
${userneed_PCAP}       ${False}
${userneed_TTI}        ${False}
${userneed_Btslog}     ${False}
${save_debug_data}     ${False}
${userneed_TPcheck}    ${False}
${userneed_PM}         ${False}    #${True}  10767 counters are on FED status utp to official 24R1 branchoff to 24R1

${IWK_CB008983_Cell3_Adaptation}    ${False}
${A_12_EI7_CL}                      ${False}
${A_13_EI7_OL}                      ${False}
${A_14_EI8_IWK}                     ${False}

*** Test Cases ***

[1]CB010767-A_14_EI8_IWK_1RxRedCapUE_with_256QAM_ASOH
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...              on TTFF environnement only FF (FDD) cells are used.
    ...              Cell3 is FDD 20Mhz (default UTE delivery)
    ...              CELL4 is FDD  5Mhz (UTE delivery is overwrittent by ReductCapa/5GC010767/custom_config_10767_rc_ASOH.yaml in 5Mhz )
    ...              Configuration set by this script :
    ...                   NRBTS.NRCELL.actRedCapUeSupport set to true, CB009384 feature is enabled
    ...                   MRBTS.NRBTS.NRCELL.cellBarredRedCap set to 0  (no barring) CB0010767 feature is enabled
    ...                   pdcpSNLengthRedCap  PDCP SN length of 12 bits for data transmission
    ...                   rlcAMDrbSNLengthRedCap  = 12
    ...
    ...                   UEid 55 1rx redcap 256 QAM on Cell3
    ...                   UE-NR-Capability-v1700:RedCapParameters-r17:supportOfRedCap-r17 on This Redcap ue
    ...
    ...              it perform:
    ...                         .  a SA call on the FDD cell 3. launch traffic
    ...                         .  set MCS=15 by radparam on second run
    ...
    ...              logs:        Snapshot, SosReport, pcap (CORE & CPRT) time of cell_setup
    ...                           + time of ue attach, TTI traces on traffic, reduce by step CQI down to 0, collect all redcap PM counter
    ...
    ...  PRECONDITIONS:
    ...              CLOUD_5G_O_H_AP_LOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
    ...              test line is well set and operational for L3 call of normal UE
    ...
    ...  TESTING TOOLS:
    ...              AirPhone, WebEM
    ...
    ...  TEST ENVIRONMENT:
    ...             HARDWARE ID:   AHLOA
    ...
    ...  REQUIRED LOGS:
    ...             Snapshot, RD.BTS log,
    ...             Cprt logs just after cell_setup for SIB1 Analysis
    ...             bip L1L2 time of UE redcap attach (register/pdusession) to check LCID and PDCP-SN size
    ...             TTI on traffic, PM legacy and 10767 from traffic up to CQI downgrade collection end
    ...
    ...  REFERENCES:           CB010767_A CFAM
    ...

    [Setup]    Run Keywords
    ...                      10767_Init Trace color
    ...    AND               10767_Create Test Suite Folder
    ...    AND               10767_Capture_session_initiating
    ${AutoSaveDebugData}     Set Variable  ${True}
    Set Global Variable      ${AutoSaveDebugData}

    #Need for this test

    ${userneed_PCAP}       Set Variable        ${True}
    ${userneed_TTI}        Set Variable        ${True}
    ${userneed_Btslog}     Set Variable        ${True}
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


    10767_Test_BandWith_SA_FDD     ${A4}    A_14_EI8_IWK=${True}
    10767_Test_BandWith_SA_FDD     ${A4}    A_14_EI8_IWK=${True}


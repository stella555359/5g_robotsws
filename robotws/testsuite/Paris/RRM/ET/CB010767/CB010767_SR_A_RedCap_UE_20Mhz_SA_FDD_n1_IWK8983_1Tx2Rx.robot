*** Settings ***
Documentation
...  DESCRIPTION:
...  this test use UTE machine CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...
...             CB010767_RedCap_Support_in_FR1_FDD  check L2ET side for redcap ue introduction
...             plus 5mhz construction with custom_config. On this base, redcap configuration is set directly by the test script
...
...             author:                 francois.tourlonnias@nokia.com
...

Resource           resources/robot/CB010767_SR_A_RedCap_UE_20Mhz_SA_FDD_n1_keywords.robot


Suite Setup        Suite Setup From Scratch
...                keepAllUeDataInCfgFile=${True}    #set in comment for robustness cfg file to 200 ue
...                automaticTeardown=FirstFail


# Suite Teardown     Test Suite Teardown for CB010767_SR_A  # If commented, we not restore the TL as original configuration. It stay like end of test
Test Teardown      10767_Test Teardown CB010767_SR_A

*** Variables ***

# variable set to ${True} to automatically save SOS report and OAM snapshot
# (by default, these information are saved only if a test is failed)
${AutoSaveDebugData}    ${False}
${target_dir}           None
${VMmonitoring}         ${False}  #will create a MONITORING directory, collect Top info each 20s and do a preprocessing of data
${debugArg}             ${False}  #${True}  True is used to see more details on console 

# Preinit for "Bouchon" cases - don't modify the value here but on keyword file
${userneed_PCAP}       ${False}
${userneed_TTI}        ${False}
${userneed_Btslog}     ${False}
${save_debug_data}     ${False}
${userneed_TPcheck}    ${False}
${userneed_PM}         ${False}

${IWK_CB008983_Cell3_Adaptation}    ${False}
${A_12_EI7_CL}                      ${False}
${A_13_EI7_OL}                      ${False}
${A_14_EI8_IWK}                     ${False}

*** Test Cases ***

[1]CB010767-A_17_EI4_IWK_1RxRedcapUE_with_CB008983
    [Tags]    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  this test use UTE machine CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    ...
    ...
    ...              on TTFF environnement only FF (FDD) cells are used. 
    ...              Cell3 is FDD 20Mhz (default UTE delivery)  ==> target for this test
    ...              Configuration set by this script :
    ...
    ...                   AHEGB RU SCF settings
    ...                   AHEGB RU Iphy.xml setting (gscn/AHEG references) 
    ...                   basic file gscn/arfcn adaptation
    ...
    ...                   NRBTS.NRCELL.actRedCapUeSupport set to true, CB009384 feature is enabled
    ...                   MRBTS.NRBTS.NRCELL.cellBarredRedCap set to 0  (no barring) CB0010767 feature is enabled
    ...                   pdcpSNLengthRedCap  PDCP SN length of 12 bits for data transmission
    ...                   rlcAMDrbSNLengthRedCap  = 12
    ...                
    ...                   UEid 51 1rx redcap on Cell3
    ...                   UE-NR-Capability-v1700:RedCapParameters-r17:supportOfRedCap-r17    1RX
    ...  
    ...              it perform:  a SA call on the CELL3 FDD cell. launch traffic
    ...              logs:        Snapshot, SosReport, pcap (CORE & CPRT) time of cell_setup 
    ...                           + time of ue attach, TTI traces on traffic, reduce by step CQI down to 0, collect all redcap PM counter
    ...
    ...  PRECONDITIONS:
    ...              CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE 
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
    ...                                  10767_Init Trace color
    ...    AND                           10767_Create Test Suite Folder
    ...    AND                           10767_Capture_session_initiating
    ${AutoSaveDebugData}                 Set Variable  ${True}
    Set Global Variable                  ${AutoSaveDebugData}
    
    ${IWK_CB008983_Cell3_Adaptation}=    Set Variable    ${True}
    Set Global Variable                  ${IWK_CB008983_Cell3_Adaptation}

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
    
    10767_Test_BandWith_SA_FDD           ${A3}



*** Settings ***
Documentation
...             CB009384_RedCap_Support_in_FR1_FDD  check L2ET side for redcap ue introduction
...               
...             author:                 francois.tourlonnias@nokia.com
...             maintainer:             francois.tourlonnias@nokia.com
...             maintainer:             philippe.daroux@nokia.com             FB2323 adaptation to new TOPO + VARIANT

Resource           resources/robot/CB009384_SR_A_RedCap_UE_20Mhz_SA_FDD_n1_keywords.robot


Suite Setup        Suite Setup From Scratch
    ...            keepAllUeDataInCfgFile=${True}    #set in comment for robustness cfg file to 200 ue
#Suite Teardown     Test Suite Teardown for CB009384_SR_A  # If commented, we not restore the TL as original configuration. It stay like end of test
Test Teardown      Test Teardown CB009384_SR_A

*** Variables ***

# variable set to ${True} to automatically save SOS report and OAM snapshot
# (by default, these information are saved only if a test is failed)
${AutoSaveDebugData}    ${False}
${target_dir}           None
${VMmonitoring}         ${False}  #will create a MONITORING directory, collect Top info each 20s and do a preprocessing of data


*** Test Cases ***

CB009384_SR_A_20_IWK4a_RedCap_UE_with_DFT_s_OFDM_for_PUSCH_pi2BPSK_is_used_for_MCS0_and_MCS1
    [Tags]    CRT    5G_RAN_FDD
    ...              CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
    ...              CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...  This script will set redcap purpose on CB008072_interaction_5GC00545_FDD_SA environnement (scf/basic),

    [Setup]    Run Keywords
    ...                       Init Trace color
    ...    AND                Create Test Suite Folder
    ...    AND                CB009384_Capture_session_initiating
    ${AutoSaveDebugData}      Set Variable  ${True}
    Set Global Variable       ${AutoSaveDebugData}
    CB009384_SR_A_20_IWK4a    ${HF_20_a3ghz_n1_AHLOA_FDD_SA_redcap}


[1]CB009384_SR_A_2_B3a_RedCap_UE_Traffic_DL_12bits_RLC_PDCP_SN
    [Tags]    CRT    5G_RAN_FDD    CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...  Goal of this script is to provide a tool helping to collect traces (redcap purpose) - recap UE L3call
    ...  
    ...  It set 2 SA ue (1 redcap (ueid2) + another not redcap) in the same cell or not & Start traffic
    ...  It will collect on a same dedicated repository config and logs files
    ...    Config:  SCF, Iphy, wts_cfg, AP & 5gnb swconfig, TargetBD file from 5gnb
    ...    logs:    Snapshot, SosReport, pcap (CORE & CPRT) time of cell_setup + time of ue attach, TTI traces on traffic, Sherpa
    ...
    ...  PRECONDITIONS:
    ...  CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD test line is well set and operational for L3 call of normal UE
    ...
    ...  TESTING TOOLS:  AirPhone, WebEM, Sherpa
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:   AHLOA
    ...
    ...  REQUIRED LOGS:        Snapshot, RD.BTS log, 
    ...                        Cprt logs just after cell_setup for SIB1 Analysis
    ...                        bip L1L2 time of UE redcap attach (register/pdusession) to check LCID and PDCP-SN size
    ...                        Sherpa since first ue attach up to end
    ...
    ...  REFERENCES:           CB009384_A CFAM
    ...

    [Setup]    Run Keywords
    ...                      Init Trace color
    ...    AND               Create Test Suite Folder
    ...    AND               CB009384_Capture_session_initiating
    ${AutoSaveDebugData}     Set Variable  ${False}
    Set Global Variable      ${AutoSaveDebugData}
                       
    Test_BandWith_SA_FDD     ${HF_20_a3ghz_n1_AHLOA_FDD_SA_redcap}

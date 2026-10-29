*** Settings ***
Documentation
...             CB009384_RedCap_Support_in_FR1_FDD  check L2ET side for redcap ue introduction
...               
...             author:                 francois.tourlonnias@nokia.com
...             maintainer:             francois.tourlonnias@nokia.com
...             maintainer:             philippe.daroux@nokia.com             FB2323 adaptation to new TOPO + VARIANT

Resource           resources/robot/CB009384_SR_A_RedCap_UE_20Mhz_SA_FDD_n1_keywords.robot


#Suite Setup        Suite Setup From Scratch
#    ...            keepAllUeDataInCfgFile=${True}    #set in comment for robustness cfg file to 200 ue
Suite Setup       Suite Setup 9384
...               yamlPathname=${CURDIR}/../../../../../custom-config/POOLING/CB009158/CB009158_G/custom_config_1227-ACH.yaml

#Suite Teardown     Test Suite Teardown for CB009384_SR_A  # If commented, we not restore the TL as original configuration. It stay like end of test
Test Teardown      Test Teardown CB009384_SR_A

*** Variables ***

# variable set to ${True} to automatically save SOS report and OAM snapshot
# (by default, these information are saved only if a test is failed)
${AutoSaveDebugData}    ${False}
${target_dir}           None
${VMmonitoring}         ${False}  #will create a MONITORING directory, collect Top info each 20s and do a preprocessing of data


*** Test Cases ***

[1]CB009384_SR_A_13_IWK3a_RedCapUE_with_5GC000792_5GC001227_5GC002426
    [Tags]    CRT    5G_RAN_FDD    CLOUD_5G_I_BO_AP_KLLL_SANSA_FS_CPRI_CMWV_FDD
    ...       CONFIGS_POOLING/5GC001227/custom_config_1227-ACH.yaml
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...  This script will set redcap purpose on 5GC001227 environneent (scf/basic),
    ...  will run [1][1.0] 5GC001227-A-B8-B9-Round-Robin-Basic and some BLER egate commands
    ...

    [Setup]    Run Keywords
    ...                      Init Trace color
    ...    AND               Create Test Suite Folder
    ...    AND               CB009384_Capture_session_initiating
    ${AutoSaveDebugData}     Set Variable  ${True}
    Set Global Variable      ${AutoSaveDebugData}
    CB009384_SR_A_13_IWK3a_RedCapUE_5GC001227_RoundRobin    ${HF_20_a3ghz_n1_AHLOA_FDD_SA_redcap}


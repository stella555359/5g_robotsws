*** Settings ***
Documentation
...                CB009384_RedCap_Support_in_FR1_FDD  check L2ET side for redcap ue introduction
...
...                author:                 francois.tourlonnias@nokia.com
...                maintainer:             francois.tourlonnias@nokia.com
...

Resource           resources/robot/CB009384_SR_A_RedCap_UE_20Mhz_SA_FDD_n1_keywords.robot

# 5GC001227 - LOCAL COPY (obsoleted test moved Feb 2026)
Resource           resources/robot/5GC001227-Common_keywords.robot

Suite Setup        Suite Setup From Scratch
    # ...            keepAllUeDataInCfgFile=${True}    #set in comment for robustness cfg file to 200 ue

#Suite Teardown     Test Suite Teardown for CB009384_SR_A  # If commented, we not restore the TL as original configuration. It stay like end of test
Test Teardown      Test Teardown CB009384_SR_A

*** Variables ***

# variable set to ${True} to automatically save SOS report and OAM snapshot
# (by default, these information are saved only if a test is failed)
${AutoSaveDebugData}    ${False}
${target_dir}           None
${VMmonitoring}         ${False}  #will create a MONITORING directory, collect Top info each 20s and do a preprocessing of data

*** Test Cases ***

CB009384_SR_A_21_Rob-redcap-8bearerPerUE
    [Tags]    5G_RAN_FDD    CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  This TC will used 8 DRB for a SA redcap call with ul dl traffic + release
    ...  Multi UE can be set on HF_20_a3ghz_n1_AHLOA_FDD_SA_redcap_Rob8bearer data base
    ...  run timing:
    ...              TL preparation+ restart = 10mn
    ...              1 sequence = 3 mn
    ...              collecte logs between 5mn and 30 mn depending if SosReport and/or Sherpa are collected


    [Setup]    Run Keywords
    ...                      Init Trace color
    ...    AND               Create Test Suite Folder
    ...    AND               CB009384_Capture_session_initiating
    ${AutoSaveDebugData}     Set Variable  ${False}
    Set Global Variable      ${AutoSaveDebugData}
    Rob-redcap-8bearerPerUE     ${HF_20_a3ghz_n1_AHLOA_FDD_SA_redcap_Rob8bearer}

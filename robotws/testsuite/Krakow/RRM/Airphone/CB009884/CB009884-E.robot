*** Settings ***
Documentation
...        maintainer:   Karol Rybak
...        contact:      karol.rybak@nokia.com
...        author:       Karol Rybak
...        description:  Test Cases for CB009884-F

Resource    ./resources/CB009884_KW.robot

Suite Setup  Prepare suite environment  egate_config=${lua_cfg_file}  x2=True
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${lua_cfg_file}=  ${CONF_DIR}/egate_NSA.lua

*** Test Cases ***
CB009884_E_ERAB_addition_to_Existing_ENDC_Connection
    [Setup]  Prepare test environment -E
    Wait For Next Full Pm Interval
    Attach UE NSA  ue_id_first=1  ue_id_last=2
    Add bearer  ue=1  bearer_id_first=3  bearer_id_last=6
    Modify UEDC session  ue_id_first=1  ue_id_last=2  by=enb  bearer_to_add=3,4,5  cause=MISC_CauseMisc_unspecified

    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55112C08004    4           NX2CC_RAB_SETUP_ACK_SENT
    ...    M55112C08003    4           NX2CC_RAB_SETUP_ATT_RCVD
    ...    M55112C08009    4           NX2CC_RAB_SETUP_RECNF_ACK

    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Detach UE NSA  ue_id_first=1  ue_id_last=2

    [Teardown]    Run Keyword And Ignore Error    Add Main BTS Metadata to Report

*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${REMOTE_HOST_IP}    10.68.161.96
${REMOTE_HOST_USER_NAME}    ute
${REMOTE_HOST_PASSWD}    uteUTE!
${REMOTE_ALIAS}    remote_alias

*** Keywords ***
CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...    Setup remote alias for remote control PC and save original SCF files and create Redundancy
    ...    Update Redundancy On BTS2 From Active To Standby And Check
    ...    Update Redundancy On BTS1 From Standby To Active And Check
    ...    Remove Redundancy And Check
    ...    Pass criteria: LNCELs NRCELs of standby BTS should be offline, LNCELs NRCELs of active BTS should be onair,
    ...    fault 4737/4738/4739 should not be raised. LNCELs should be onair after Redundancy removed.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 16.01.2023 - Commit to GIT
    ...    - 25.04.2024 - Xu Yuyan New case for CB009939-A case 9/10 based on CM__CB008824_003_Do_Controlled_Switchover

    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    PHASE-CRT    API
    Log To Console    ${TEST_NAME} start.
    Step 1: Case Precondition
    Step 2: Update Redundancy On BTS2 From Active To Standby And Check
    Step 3: Update Redundancy On BTS1 From Standby To Active And Check
    Step 4: Remove Redundancy And Check

Step ${index}: Case Precondition
    Log To Console    Step ${index}: Case Precondition
    ${is_scf_not_saved}    Run Keyword And Return Status    Variable Should Not Exist    ${BTS_scf_initial}
    ${BTS_scf}    Run Keyword If    ${is_scf_not_saved}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
    ${BTS_scf}    Set Variable If    ${is_scf_not_saved}    ${BTS_scf}    ${BTS_scf_initial}
    Set Test Variable    ${BTS1_scf_initial}    ${BTS_scf}
    Remote BTS Setup   ${REMOTE_HOST_IP}    ${REMOTE_HOST_USER_NAME}    ${REMOTE_HOST_PASSWD}    ${REMOTE_ALIAS}
    ${BTS_scf}    Admin Collect scf.xml with timestamp TAF    alias=${REMOTE_ALIAS}    folder_path=${BTSFiles}
    Set Test Variable    ${BTS2_scf_initial}    ${BTS_scf}
    ${bts_obj}    coam.Get parameters for all    BTS
    ${bts_id}    Convert To String    ${bts_obj[0].btsId}
    Set Test Variable    ${MRBTS_ID_1}    ${bts_id}
    ${bts_obj}    coam.Get parameters for all    BTS    alias=${REMOTE_ALIAS}
    ${bts_id}    Convert To String    ${bts_obj[0].btsId}
    Set Test Variable    ${MRBTS_ID_2}    ${bts_id}
    Set Test Variable    ${NEED_COMMISSION}    ${True}
    ${parameters_dic1}    Create Dictionary    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=standby
    ${parameters_dic2}    Create Dictionary    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=active
    Config Redundancy    ${MRBTS_ID_1}    create    ${parameters_dic1}
    Config Redundancy    ${MRBTS_ID_2}    create    ${parameters_dic2}    ${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}
    ${redundancy_alarm_1}    Create Dictionary    faultId=${4739}
    ${redundancy_alarm_2}    Create Dictionary    faultId=${4737}
    ${redundancy_alarm_3}    Create Dictionary    faultId=${4738}
    ${ALARMS_4737_4738_4739}    Create List    ${redundancy_alarm_1}    ${redundancy_alarm_2}    ${redundancy_alarm_3}
    Set Test Variable    ${ALARMS_4737_4738_4739}
    Set Test Variable   ${lte_blocked_state}    administrativeState=unlocked, operationalState=disabled, blockingState=Blocked
    Set Test Variable   ${nr_blocked_state}    administrativeState=Unlocked, operationalState=disabled, blockingState=Blocked

Step ${index}: Update Redundancy On BTS2 From Active To Standby And Check
    Log To Console    Step ${index}: Update Redundancy On BTS2 From Active To Standby And Check
    ${parameters_dic}    Create Dictionary    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=standby
    Config Redundancy    ${MRBTS_ID_2}    update    ${parameters_dic}    ${REMOTE_ALIAS}
    Log To Console    Check BTS2
    ${rat_status}    Get Rat Status    alias=${REMOTE_ALIAS}
    Should Be Equal As Strings    ${rat_status["nr"]}    ALL_DISABLED
    Check SBTS Redundancy States    standby    standby    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS}
    #ute_admin_infomodel.wait_for_infomodel_event    create //RESET_RAT_REQ-*/RESULT-1 [status=Succeeded]    timeout=600    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}
    Log To Console    Check BTS1
    Check SBTS Redundancy States    standby    standby    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}
    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces

Step ${index}: Update Redundancy On BTS1 From Standby To Active And Check
    Log To Console    Step ${index}: Update Redundancy On BTS1 From Standby To Active And Check
    ${parameters_dic}    Create Dictionary    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=active
    Config Redundancy    ${MRBTS_ID_1}    update    ${parameters_dic}
    Log To Console    Check BTS1
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=300    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}
    Wait Until Keyword Succeeds    10x    30 sec    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces
    Log To Console    Check BTS2
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}    alias=${REMOTE_ALIAS}
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}

Step ${index}: Remove Redundancy And Check
    Log To Console    Step ${index}: Remove Redundancy And Check
    Log To Console    Block RATs
    ${LNCEL_ids}    coam.Get ids for all    LNCEL
    ${NRCEL_ids}    coam.Get ids for all    NRCEL
    Run Keyword If    ${LNCEL_ids}    coam.block_rat    LTE
    Sleep    2s
    Run Keyword If    ${NRCEL_ids}    coam.block_rat    NR
    Sleep    2s
    Run Keyword If    ${LNCEL_ids}    coam.block_rat    LTE    connection=${REMOTE_ALIAS}
    Sleep    10s
    Run Keyword If    ${NRCEL_ids}    coam.block_rat    NR    connection=${REMOTE_ALIAS}
    Log To Console    Delete
    ${parameters_dic}    Create Dictionary
    Config Redundancy    ${MRBTS_ID_1}    delete    ${parameters_dic}
    Config Redundancy    ${MRBTS_ID_2}    delete    ${parameters_dic}    ${REMOTE_ALIAS}
    Log To Console    Check BTS2
    ute_admin_infomodel.connect_infomodel    alias=${REMOTE_ALIAS}
    ute_admin_infomodel.wait_for_infomodel_event    create //RESET_RAT_REQ-*/RESULT-1 [status=Succeeded]    timeout=900    alias=${REMOTE_ALIAS}
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=600    expected_LTE_states=${lte_blocked_state}
    ...    expected_NR_states=${cells_NR_expected_state}    alias=${REMOTE_ALIAS}
    #All the RAT and cells Blocked.
    ${rat_status}    Get Rat Status    alias=${REMOTE_ALIAS}
    Run Keyword If    ${NRCEL_ids}    Should Be Equal As Strings    ${rat_status["nr"]}    ALL_ENABLED
    Run Keyword If    ${LNCEL_ids}    Should Be Equal As Strings    ${rat_status["lte"]}    ALL_DISABLED
    ${alarm_4614}    Create Dictionary    faultId=${4614}
    ${ALARMS_4614}    Create List    ${alarm_4614}
    Run Keyword If    ${LNCEL_ids}    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}
    ...    expected_patterns=@{ALARMS_4614}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    ...    ELSE    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Log To Console    Check BTS1
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=600    expected_LTE_states=${lte_blocked_state}
    ...    expected_NR_states=${nr_blocked_state}
    #All the RAT and cells Blocked.
    ${rat_status}    Get Rat Status
    Run Keyword If    ${NRCEL_ids}    Should Be Equal As Strings    ${rat_status["nr"]}    ALL_DISABLED
    Run Keyword If    ${LNCEL_ids}    Should Be Equal As Strings    ${rat_status["lte"]}    ALL_DISABLED
    Admin Check Active Alarms TAF    expected_patterns=@{ALARMS_4614}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Log To Console    Unblock RATs
    sleep    120s
    Run Keyword If    ${LNCEL_ids}    coam.unblock_rat    LTE
    Run Keyword If    ${NRCEL_ids}    coam.unblock_rat    NR
    Run Keyword If    ${LNCEL_ids}    coam.unblock_rat    LTE    connection=${REMOTE_ALIAS}
    Set Test Variable    ${NEED_COMMISSION}    ${False}

Case Special Teardown
    Log To Console    Case Special Teardown
    ${ims_path}    Set variable    ${BTS Files}/IM/${REMOTE_ALIAS}_informodel.ims2
    Run Keyword If Test Failed    Run Keyword And Return Status    Collect Remote Syslog Informodel And Snapshot    alias=${REMOTE_ALIAS}
    Run Keyword If    ${NEED_COMMISSION}    coam.Perform Commissioning
    ...    ${MRBTS_ID_1}    ${BTS1_scf_initial}    skip_parameter_relation_errors=true    timeout=600
    Run Keyword If    ${NEED_COMMISSION}    coam.Perform Commissioning
    ...    ${MRBTS_ID_2}    ${BTS2_scf_initial}    skip_parameter_relation_errors=true    timeout=600    connection=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Wait Until Keyword Succeeds    5x    60 sec    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=60
    ...    connection=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    5x    60 sec    coam.assert_every    NRCEL    ${cells_NR_expected_state}    timeout=60
    ...    connection=${REMOTE_ALIAS}
    Common Test Teardown SBTS
    taf_syslog.Teardown All Aliases For Syslog
    Teardown Infomodel    alias=${REMOTE_ALIAS}


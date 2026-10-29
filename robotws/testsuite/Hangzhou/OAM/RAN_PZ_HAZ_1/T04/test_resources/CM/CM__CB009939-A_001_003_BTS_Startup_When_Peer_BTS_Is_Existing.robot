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
CM__CB009939-A_001_003_BTS_Startup_When_Peer_BTS_Is_Existing
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...    Setup remote alias for remote control PC and save original SCF files
    ...    Create Redundancy On BTS1 And Check
    ...    Reset On BTS1 And Check When BTS2 No Redundancy（CB009939_case1）
    ...    Create Redundancy On BTS2 And Check
    ...    Reset On BTS1 And Check When BTS2 Is Active（CB009939_case1）
    ...    Delta Commissioning With Reset And Lock Cells On BTS2 And Check（CB009939_case3）
    ...    Remove Redundancy And Check
    ...  Pass criteria: LNCELs NRCELs of standby BTS should be offline, LNCELs NRCELs of active BTS should be onair,
	...    fault 4737 4738 4739 should be raised and cleared as expected. LNCELs NRCELs should be onair after Redundancy removed.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 25.04.2024 - Xu Yuyan New case for CB009939-A case 1/3(scenario2) based on CM__CB008824_002_Configure_Baseband_Redundancy_Mode

    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    PHASE-CRT    API
    Log To Console    ${TEST_NAME} start.
    Step 1: Case Precondition
    Step 2: Create Redundancy On BTS1 And Check
    Step 3: Reset On BTS1 And Check When BTS2 No Redundancy
    Step 4: Create Redundancy On BTS2 And Check
    Step 5: Reset On BTS1 And Check When BTS2 Is Active
    Step 6: Delta Commissioning With Reset And Lock Cells On BTS2 And Check
    Step 7: Remove Redundancy And Check

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
    ${nrcells_list_bts2}    Fetch ID Mapping From Admin For Cells    NRBTS    alias=${REMOTE_ALIAS}
    Set Test Variable    ${NRCells_List_BTS2}    ${nrcells_list_bts2}
    ${redundancy_alarm_1}    Create Dictionary    faultId=${4737}
    ${redundancy_alarm_2}    Create Dictionary    faultId=${4738}
    ${redundancy_alarm_3}    Create Dictionary    faultId=${4739}
    ${ALARMS_4737_4738_4739}    Create List    ${redundancy_alarm_1}    ${redundancy_alarm_2}    ${redundancy_alarm_3}
    Set test Variable    ${ALARMS_4737_4738_4739}
    ${ALARMS_4739}    Create List    ${redundancy_alarm_3}
    Set test Variable    ${ALARMS_4739}

Step ${index}: Create Redundancy On BTS1 And Check
    Log To Console    Step ${index}: Create Redundancy On BTS1 And Check
    Set Test Variable    ${NEED_COMMISSION}    ${True}
    ${parameters_dic}    Create Dictionary    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=standby
    Config Redundancy    ${MRBTS_ID_1}    create    ${parameters_dic}
    Log To Console    Check BTS1
    Check SBTS Redundancy States    standby    empty    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}
    Wait Until Keyword Succeeds    10x    60 sec    Admin Check Active Alarms TAF    expected_patterns=@{ALARMS_4739}
    Wait Until Keyword Succeeds    10x    60 sec    Check BTS Interfaces
    Log To Console    Check BTS2
    Check SBTS Redundancy States    empty    standby    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}    alias=${REMOTE_ALIAS}
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4739}
    Check BTS Interfaces    alias=${REMOTE_ALIAS}

Step ${index}: Reset On BTS1 And Check When BTS2 No Redundancy
    Log To Console    Step ${index}: Reset On BTS1 And Check When BTS2 No Redundancy
    coam.reset_site
    Log To Console    Check BTS1
    Check SBTS Redundancy States    standby    empty    ${MRBTS_ID_1}    timeout=1200    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}
    Wait Until Keyword Succeeds    10x    60 sec    Admin Check Active Alarms TAF    expected_patterns=@{ALARMS_4739}
    Wait Until Keyword Succeeds    10x    60 sec    Check BTS Interfaces
    Log To Console    Check BTS2
    ute_admin_infomodel.teardown_infomodel    alias=${REMOTE_ALIAS}
    ute_admin_infomodel.Setup Infomodel    address=${SMOD1['TRS_IP']}    port=443    timeout=90    use_ssl=True
    ...    admin_api_log_dir=${BTS Files}    alias=${REMOTE_ALIAS}    remote_host=${REMOTE_HOST_IP}
    ...    remote_host_username=${REMOTE_HOST_USER_NAME}    remote_host_password =${REMOTE_HOST_PASSWD}
    Check SBTS Redundancy States    empty    standby    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}    timeout=600    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    60 sec    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4739}
    Wait Until Keyword Succeeds    10x    60 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}

Step ${index}: Create Redundancy On BTS2 And Check
    Log To Console    Step ${index}: Create Redundancy On BTS2 And Check
    ${parameters_dic}    Create Dictionary    redundancyGroupId=${MRBTS_ID_1}    redundancyRole=active
    Config Redundancy    ${MRBTS_ID_2}    create    ${parameters_dic}    ${REMOTE_ALIAS}
    Log To Console    Check BTS2
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}    alias=${REMOTE_ALIAS}
    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    60 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}
    Log To Console    Check BTS1
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}
    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    60 sec    Check BTS Interfaces

Step ${index}: Reset On BTS1 And Check When BTS2 Is Active
    Log To Console    Step ${index}: Reset On BTS1 And Check When BTS2 Is Active
    coam.reset_site
    Log To Console    Check BTS1
    Wait Until Keyword Succeeds    10x    60 sec    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}
    ...    expected_LTE_states=${cells_LTE_offline_state}    expected_NR_states=${cells_NR_offline_state}
    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    60 sec    Check BTS Interfaces
    Log To Console    Check BTS2
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    60 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}

Step ${index}: Delta Commissioning With Reset And Lock Cells On BTS2 And Check
    Log To Console    Step ${index}: Delta Commissioning With Reset And Lock Cells On BTS2 And Check
    ${current_value}    Get Parameter Value From WebEM
    ...    MRBTS-${MRBTS_ID_2}/MNL-1/MNLENT-1/FEATCADM-1    actMplaneFronthaulFirewall    alias=${REMOTE_ALIAS}
    ${value_to_set}    Set Variable If    "${current_value}"=="true"    false    true
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${MRBTS_ID_2}_${time}
    coam.append_parameter_update_to_delta
    ...    MRBTS-${MRBTS_ID_2}/MNL-1/MNLENT-1/FEATCADM-1    actMplaneFronthaulFirewall    ${value_to_set}    ${MRBTS_ID_2}_${time}
    #all cells locked
    FOR    ${nrcell}    IN    @{NRCells_List_BTS2}
        ${nrcell_dn}    Get From Dictionary    ${nrcell}    configuration
        coam.append_parameter_update_to_delta    ${nrcell_dn}    administrativeState    Locked    ${MRBTS_ID_2}_${time}
    END
    ${delta_json}    coam.get_delta    delta_id=${MRBTS_ID_2}_${time}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}    connection=${REMOTE_ALIAS}
    Log To Console    Check BTS2
    Check SBTS Redundancy States    active    standby    ${MRBTS_ID_1}    timeout=1200    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_locked_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    60 sec    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    20x    90 sec    Check BTS Interfaces    alias=${REMOTE_ALIAS}
    ...    ngLinkStatus=Inactive    xnLinkStatus=unavailable    x2ToGnbLinkStatus=unavailable
    Log To Console    Check BTS1
    Check SBTS Redundancy States    standby    active    ${MRBTS_ID_1}    expected_LTE_states=${cells_LTE_offline_state}
    ...    expected_NR_states=${cells_NR_offline_state}
    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Wait Until Keyword Succeeds    10x    60 sec    Check BTS Interfaces
    Log To Console    Unlocked Cells
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${MRBTS_ID_2}_${time}
    FOR    ${nrcell}    IN    @{NRCells_List_BTS2}
        ${nrcell_dn}    Get From Dictionary    ${nrcell}    configuration
        coam.append_parameter_update_to_delta    ${nrcell_dn}    administrativeState    Unlocked    ${MRBTS_ID_2}_${time}
    END
    ${delta_json}    coam.get_delta    delta_id=${MRBTS_ID_2}_${time}
    ${rel_validate}    coam.perform_delta_recommissioning    ${delta_json}    connection=${REMOTE_ALIAS}
   Wait Until Keyword Succeeds    20 min    30 sec
    ...    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=60    connection=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    20 min    30 sec
    ...    coam.assert_every    NRCEL    ${cells_NR_expected_state}    timeout=60    connection=${REMOTE_ALIAS}

Step ${index}: Remove Redundancy And Check
    Log To Console    Step ${index}: Remove Redundancy And Check
    ${parameters_dic}    Create Dictionary
    Config Redundancy    ${MRBTS_ID_1}    delete    ${parameters_dic}
    Config Redundancy    ${MRBTS_ID_2}    delete    ${parameters_dic}    ${REMOTE_ALIAS}
    #For bad CNN PR767417, reset site if F1900 raised.
    ${fault_str}    Set Variable    faultId=1900
    ${is_1900_raised_BTS1}    Run Keyword And Return Status
    ...    coam.assert_alarm_active    ${fault_str}    timeout=240s
    ${is_1900_raised_BTS2}    Run Keyword And Return Status
    ...    coam.assert_alarm_active    ${fault_str}    timeout=240s   connection=${REMOTE_ALIAS}
    Run Keyword If    ${is_1900_raised_BTS1}    Run Keywords    coam.reset_site    AND    Sleep    240s
    Run Keyword If    ${is_1900_raised_BTS2}    Run Keywords    coam.reset_site    connection=${REMOTE_ALIAS}    AND    Sleep    240s
    Log To Console    Check BTS2
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=300    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}    alias=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Admin Check Active Alarms TAF    alias=${REMOTE_ALIAS}    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Log To Console    Check BTS1
    Check SBTS Redundancy States    empty    empty    ${MRBTS_ID_1}    timeout=300    expected_LTE_states=${cells_LTE_expected_state}
    ...    expected_NR_states=${cells_NR_expected_state}
    Wait Until Keyword Succeeds    10x    30 sec    Admin Check Active Alarms TAF    unexpected_patterns=@{ALARMS_4737_4738_4739}
    Set Test Variable    ${NEED_COMMISSION}    ${False}

Case Special Teardown
    Log    Case Special Teardown    console=${True}
    ${ims_path}    Set variable    ${BTS Files}/IM/${REMOTE_ALIAS}_informodel.ims2
    Run Keyword If Test Failed    Run Keyword And Return Status    Collect Remote Syslog Informodel And Snapshot    alias=${REMOTE_ALIAS}
    Run Keyword If    ${NEED_COMMISSION}    coam.Perform Commissioning
    ...    ${MRBTS_ID_1}    ${BTS1_scf_initial}    skip_parameter_relation_errors=true    timeout=600
    Run Keyword If    ${NEED_COMMISSION}    coam.Perform Commissioning
    ...    ${MRBTS_ID_2}    ${BTS2_scf_initial}    skip_parameter_relation_errors=true    timeout=600    connection=${REMOTE_ALIAS}
    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Wait Until Keyword Succeeds    5x    60 sec    coam.assert_every    LNCEL    ${cells_LTE_expected_state}    timeout=60
    ...    connection=${REMOTE_ALIAS}
    Common Test Teardown SBTS
    taf_syslog.Teardown All Aliases For Syslog
    Teardown Infomodel    alias=${REMOTE_ALIAS}
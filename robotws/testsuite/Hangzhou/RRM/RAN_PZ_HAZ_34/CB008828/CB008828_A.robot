*** Settings ***
Resource    resources/common_keywords.robot
Library     resources/common_keywords.py
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.config.wts       WITH NAME    wts
Documentation
...    author: Yang Di
...    maintainer: Yang Di (di.yang@nokia-sbell.com)
...    release: 24R2

Test Teardown    CB008828 Common Test Teardown

Suite Setup    Suite Case Setup for TL1920

Suite Teardown   AP_startup.Common Suite Teardown

*** Variables ***
${RECREATE_WIRESHARK_FLAG}    ${TRUE}
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
CB008828_SR_002_A#B1_Classical_gNB_startup_with_2000_network_slices_ALT1
    [Setup]     Test Case A Setup
    [Tags]    002_A
    check wireshark log    ${CURDIR}${/}A2A_002_A${/}a2a_plmn.ini    wait_string=E1SetupResponse

CB008828_SR_004_A#B2_Cell_setup_with_2000_network_slices_on_gNB_startup_ALT1
    [Setup]     Test Case A Setup    scf_path=${004_A_SCF_PATH}
    [Tags]    004_A
    check wireshark log    ${CURDIR}${/}A2A_004_A${/}a2a_plmn.ini    wait_string=XnSetupResponse
    wait until keyword succeeds    3 min    10 sec    NG and Xn Link Should be active
    Continuous Network Slices State Should be enabled
    Check Slices in SERVEDAMF

CB008828_SR_008_A#B3_Successful_PDU_Session_Resource_Setup_ALT1
    [Setup]     Test Case A Setup   cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_026_D}    scf_path=${026_D_SCF_PATH}
    ...    wireshark_flag=${FALSE}
    [Tags]    008_A
    AP_lib.Start To Capture Wireshark Log    008_A
    6 SA UEs Attach on cell1
    Stop Traffic and Release PDU
    check wireshark log    ${CURDIR}${/}A2A_008_A${/}a2a_plmn.ini    name=008_A
    ...    wait_string=PDUSessionResourceReleaseResponse::48

CB008828_SR_010_A#B4_Runtime_cell_setup_with_more_than_1024_network_slices_ALT1
    [Setup]     Test Case A Setup   cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_010_A}    scf_path=${010_A_4C_SCF_PATH}
#    [Setup]     Test Case A Setup   cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_010_A}    scf_path=${010_A_SCF_PATH}
    ...    wireshark_flag=${FALSE}
    [Tags]    010_A
    Online Cell And TRACKINGAREAs Deletion
    AP_lib.Start To Capture Wireshark Log    010_A
#    Add 1990 SNSSAIs
    Online Cell And TRACKINGAREAs Addition
    check wireshark log    ${CURDIR}${/}A2A_010_A${/}a2a_plmn.ini    name=010_A
    ...    wait_string=NGRANNodeConfigurationUpdate::8
    Check NRCELL onair
    wait until keyword succeeds    3x    20 sec    Continuous Network Slices State Should be enabled
    Check Slices in SERVEDAMF
    6 SA UEs Attach with Basic Setup

CB008828_SR_013_A#B5_Administrative_lock_of_more_than_20_network_slices_for_enabled_cell
    [Setup]     Test Case A Setup   cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_026_D}    scf_path=${026_D_SCF_PATH}
    ...    wireshark_flag=${FALSE}
    [Tags]    013_A
    AP_lib.Start To Capture Wireshark Log    013_A
    Lock 105 SNSSAIs
    check wireshark log    ${CURDIR}${/}A2A_013_A${/}a2a_plmn.ini    name=013_A
    ...    wait_string=NGRANNodeConfigurationUpdate
    Check NRCELL onair
    wait until keyword succeeds    3x    20 sec    Network Slices State Should be disabled
    Not Locked Network Slices State Should be enabled
    6 SA UEs Attach on cell1
    Stop PDU and release UE
    PDU Session Cannot be Setup for Locked Network Slice

CB008828_SR_014_A#B6_Administrative_unlock_of_more_than_20_network_slices_for_enabled_cell
    [Setup]     Test Case A Setup   cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_026_D}    scf_path=${026_D_SCF_PATH}
    ...    wireshark_flag=${FALSE}
    [Tags]    014_A
    Lock 105 SNSSAIs
    AP_lib.Start To Capture Wireshark Log    014_A
    Unlock 105 SNSSAIs
    check wireshark log    ${CURDIR}${/}A2A_014_A${/}a2a_plmn.ini    name=014_A
    ...    wait_string=NGRANNodeConfigurationUpdate
    Check NRCELL onair
    wait until keyword succeeds    3x    20 sec    Continuous Network Slices State Should be enabled
    6 SA UEs Attach on cell1
    Stop PDU and release UE
    PDU Session Can be Setup for Unlocked Network Slice

CB008828_SR_015_A#B7_Online_addition_of_more_than_20_network_slices_for_enabled_cell
    [Setup]     Test Case A Setup    scf_path=${015_A_SCF_PATH}    wireshark_flag=${FALSE}
    [Tags]    015_A
    AP_lib.Start To Capture Wireshark Log    015_A
    Add 105 SNSSAIs Case 15A
    check wireshark log    ${CURDIR}${/}A2A_015_A${/}a2a_plmn.ini    name=015_A
    ...    wait_string=NGRANNodeConfigurationUpdate
    Check NRCELL onair
    wait until keyword succeeds    3x    20 sec    Continuous Network Slices State Should be enabled
    6 SA UEs Attach with Basic Setup

CB008828_SR_018_A#B8_Deletion_of_more_than_20_disabled_network_slices_for_enabled_cell_ALT1
    [Setup]     Test Case A Setup   wireshark_flag=${FALSE}
    [Tags]    018_A
    Lock 100 SNSSAIs Case 18A
    AP_lib.Start To Capture Wireshark Log    018_A
    Delete 100 SNSSAIs
    check wireshark log    ${CURDIR}${/}A2A_018_A${/}a2a_plmn.ini    name=018_A
    Check NRCELL onair
    6 SA UEs Attach with Basic Setup

CB008828_SR_020_A#B9_Online_activation_of_feature_CB008828_ALT1
    [Setup]    Run Keywords     Test Case A Setup    scf_path=${010_A_SCF_PATH}   wireshark_flag=${FALSE}   AND
    ...    Disable actSliceNumExt and actRanSharing
    [Tags]    020_A
    Wait Until Keyword Succeeds    5x    1min    Enable Actslicenumext
    Check NRCELL onair
    wait until keyword succeeds    3x    10 sec    Continuous Network Slices State Should be enabled    last_slice=10
    AP_lib.Start To Capture Wireshark Log    020_A
    One PDU Session Can be Setup
    check wireshark log    ${CURDIR}${/}A2A_020_A${/}a2a_plmn.ini    name=020_A
    ...    wait_string=InitialContextSetupResponse

CB008828_SR_022_A#B10_Online_deactivation_of_feature_CB008828_ALT1
    [Setup]    Test Case A Setup    scf_path=${022_A_SCF_PATH}   wireshark_flag=${FALSE}
    [Tags]    022_A
    AP_lib.Start To Capture Wireshark Log    022_A
    Disable actSliceNumExt
    check wireshark log    ${CURDIR}${/}A2A_022_A${/}a2a_plmn.ini    name=022_A
    Check NRCELL onair
    wait until keyword succeeds    3x    10 sec    Case 022_A Network Slices State Should be enabled
    6 SA UEs Attach with Basic Setup

CB008828_SR_026_D_check_legacy_counters_M55160_M55161
    [Setup]    Test Case 026_D Setup
    [Tags]    026_D
    Enable 5GC002637 and CB006898
    6 NSA UEs Attach on cell1
    Verify M55160 Counters For Nsa Users
    NSA UEs Release
    6 SA UEs Attach on cell1
    Verify M55161 Counters For Sa Users

CB008828_SR_027_D_check_legacy_counters_M55352_M55159_M55328
    [Setup]    Test Case 027_D Setup
    [Tags]    027_D
    6 SA UEs Attach on cell1
    Verify M55159 M55352 M55328 Counters
    Stop PDU and release UE

CB008828_SR_019_A#B9_Online_activation_of_feature_CB008828
    [Setup]    Run Keywords     Test Case A Setup   scf_path=${019_A_SCF_PATH}    wireshark_flag=${FALSE}   AND
    ...    Disable actSliceNumExt
    [Tags]    019_A
    AP_lib.Start To Capture Wireshark Log    019_A
    Add 1980 SNSSAIs and Enable ActSliceNumExt
    check wireshark log    ${CURDIR}${/}A2A_019_A${/}a2a_plmn.ini    name=019_A
    ...    wait_string=NGRANNodeConfigurationUpdate
    Check NRCELL onair
    wait until keyword succeeds    2x    20 sec    Continuous Network Slices State Should be enabled
    Check Slices in SERVEDAMF
    6 SA UEs Attach with Basic Setup

*** Keywords ***
Test Case A Setup
    [Arguments]   ${cfg_filepath}=${EPCSIM_CFG_PATH_SANSA_TDD}    ${scf_path}=${SBTS00_SCF_PATH}
    ...    ${wireshark_flag}=${True}
    _Create Test Log Directory
    Commisioning Case Scf    scf_path=${scf_path}
#    Set param Based On The Release    ${wireshark_flag}
    Set Test Variable    ${WIRESHARK_FLAG}  ${wireshark_flag}
    Prepare Test Environement And Reach Onair    perform_tl_reset=${RESET_TL}
    ...   cfg_filepath=${cfg_filepath}
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    Disable actSliceAwareScheduler
    Enable Actransharing
    Enable Actslicenumext
    Get Initial Active Faults

Test Case 026_D Setup
    _Create Test Log Directory
    Commisioning Case Scf
#    Set param Based On The Release
    Prepare Test Environement And Reach Onair    perform_tl_reset=${RESET_TL}
    ...   cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_026_D}
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    Configure NRPMQAP
    Enable M55160 and M55161
    Enable Actslicenumext
    Get Initial Active Faults

6 NSA UEs Attach on cell1
    FOR    ${ue_id}    IN RANGE    11    17
        NSA UE attach and trigger ENDC with GNB2    ue_id=${ue_id}
        Trigger NSA UE Traffic    ue_id=${ue_id}
    END

NSA UEs Release
    FOR    ${ue_id}    IN RANGE    11    17
        Stop Traffic NSA UE and release    ue_id=${ue_id}
    END

Test Case 027_D Setup
    _Create Test Log Directory
    Commisioning Case Scf
#    Set param Based On The Release
    Prepare Test Environement And Reach Onair    perform_tl_reset=${RESET_TL}
    ...   cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_026_D}
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    Enable M55352 M55159 M55328
    Enable Actslicenumext
    Get Initial Active Faults


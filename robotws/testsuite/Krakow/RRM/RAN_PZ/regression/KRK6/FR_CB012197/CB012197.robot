*** Settings ***
Documentation
...    author: Mikolaj Borkowski
...    contact: mikolaj.borkowski@nokia.com

Resource   testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB012197/resources/suite_specific_keywords.robot


Suite Setup    Common Suite Setup With OnAir Test Line Preparation
...    increase_timeout_for_update_sw=1800
...    swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT9SK153/swconfig.txt
Test Setup    Run keywords    Log Action To Console    Start test
...           AND            Common Preconditions
Suite Teardown    Common Suite Teardown

*** Variables ***
${logs_path}             ${OUTPUTDIR}
${RP_CA}                 VRF_OAM
@{CUSTOMERS_LIST}=       Generic
${RP_LOCATION}           VRF_KRK
${RP_ORGANIZATION}       VRF_KRK_T06
${EMAIL_RECIPIENTS}      None

*** Test Cases ***
CB012197_11_General_SiSo_Cell_block_and_unblock
    General SiSo Cell block and unblock
    [Teardown]    Run keywords    Log Action To Console    End test
    ...           AND            Common Postconditions

CB012197_16_General_SiSo_BB_sub-unit_reset_with_L3_call
    taf.ue.Require UE                                        ${UE_ALIAS}          COMMERCIAL

    Log Action To Console    ============================ Verify L3 call for 1x8CC ===============================
    Block RU      bts_id=0    radio_unit_id=4
    Verify L3 call for 1x8CC                                 ue_type=${UE_ALIAS}
    ...                                                      desired_5g_cell_pci=${UE_ATTACH_5G_CELL_ID_50}
    Unblock RU    bts_id=0    radio_unit_id=4
    Wait Until Keyword Succeeds    360 seconds    15 seconds    gnbcell.verify_all_cells_statuses
    ...            cell_type=all
    ...            blocking_state=unblocked    availability_status=online    operational_state=enabled
    ...            procedural_status=configured    administrative_state=unlocked    usage_state=${None}
    ...            barring_status=unbarred

    Log Action To Console    ============================ Verify L3 call for 1x4CC ===============================
    Block RU      bts_id=0    radio_unit_id=6
    Verify L3 call for 1x4CC                                 ue_type=${UE_ALIAS}
    ...                                                      desired_5g_cell_pci=${UE_ATTACH_5G_CELL_ID_40}
    Unblock RU    bts_id=0    radio_unit_id=6
    Wait Until Keyword Succeeds    360 seconds    15 seconds    gnbcell.verify_all_cells_statuses
    ...            cell_type=all
    ...            blocking_state=unblocked    availability_status=online    operational_state=enabled
    ...            procedural_status=configured    administrative_state=unlocked    usage_state=${None}
    ...            barring_status=unbarred
    Repeat Keyword                                           1 times
    ...                                                      Reset BBMOD and check alarms
    ...                                                      bb_mod_id=1
    Repeat Keyword                                           1 times
    ...                                                      Reset BBMOD and check alarms
    ...                                                      bb_mod_id=2
    Repeat Keyword                                           1 times
    ...                                                      Reset BBMOD and check alarms
    ...                                                      bb_mod_id=3

    Log Action To Console    ============================ Verify L3 call for 1x8CC ===============================
    Block RU      bts_id=0    radio_unit_id=4
    Verify L3 call for 1x8CC                                 ue_type=${UE_ALIAS}
    ...                                                      desired_5g_cell_pci=${UE_ATTACH_5G_CELL_ID_50}
    Unblock RU    bts_id=0    radio_unit_id=4
    Wait Until Keyword Succeeds    360 seconds    15 seconds    gnbcell.verify_all_cells_statuses
    ...            cell_type=all
    ...            blocking_state=unblocked    availability_status=online    operational_state=enabled
    ...            procedural_status=configured    administrative_state=unlocked    usage_state=${None}
    ...            barring_status=unbarred

    Log Action To Console    ============================ Verify L3 call for 1x4CC ===============================
    Block RU      bts_id=0    radio_unit_id=6
    Verify L3 call for 1x4CC                                 ue_type=${UE_ALIAS}
    ...                                                      desired_5g_cell_pci=${UE_ATTACH_5G_CELL_ID_40}
    Unblock RU    bts_id=0    radio_unit_id=6
    [Teardown]    CB012197 General_SiSo_BB_sub-unit_reset_with_L3_call Test Teardown

#CB012197_35_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    [Timeout]    20h
#    General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot

CB012197_36_SiSo_SM_NR_RAT_reset
    Check BTS and RATs states
    taf.ue.Require UE                                        ${UE_ALIAS}          COMMERCIAL
    Block RU      bts_id=0    radio_unit_id=4
    Verify Attach and Detach Procedure   ue_type=S22
    ...                                  desired_5g_cell_pci=${UE_ATTACH_5G_CELL_ID_50}
    Unblock RU    bts_id=0    radio_unit_id=4
    Block RU      bts_id=0    radio_unit_id=6
    Verify Attach and Detach Procedure   ue_type=S22
    ...                                  desired_5g_cell_pci=${UE_ATTACH_5G_CELL_ID_40}
    Unblock RU    bts_id=0    radio_unit_id=6
    NR RAT Reset
    Wait Until Keyword Succeeds    10 min    10 seconds    gnbcell.verify_all_cells_statuses
    ...            cell_type=all
    ...            blocking_state=unblocked    availability_status=online    operational_state=enabled
    ...            procedural_status=configured    administrative_state=unlocked    usage_state=${None}
    ...            barring_status=unbarred
    Block RU      bts_id=0    radio_unit_id=4
    Verify Attach and Detach Procedure   ue_type=S22
    ...                                  desired_5g_cell_pci=${UE_ATTACH_5G_CELL_ID_50}
    Unblock RU    bts_id=0    radio_unit_id=4
    Block RU      bts_id=0    radio_unit_id=6
    Verify Attach and Detach Procedure   ue_type=S22
    ...                                  desired_5g_cell_pci=${UE_ATTACH_5G_CELL_ID_40}
    Unblock RU    bts_id=0    radio_unit_id=6
    [Teardown]    CB012197 Test Teardown with waiting for all cells to be on air and UE detach

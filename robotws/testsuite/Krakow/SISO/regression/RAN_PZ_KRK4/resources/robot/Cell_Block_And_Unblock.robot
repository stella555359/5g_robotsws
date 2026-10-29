*** Settings ***
Documentation
...    Implementation of Cell_Block_And_Unblock test case
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com

Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    gnbalarm
Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    gnbscf
Library     ../python/DataTransferOperations.py    WITH NAME    data_transfer
Library     ../python/CellOperations.py   WITH NAME    cell_keywords


*** Keywords ***
Cell_Block_And_Unblock
    [Documentation]
    ...    Test verifies BTS behavior during block/unblock cells from multisector configuration.
    ...    ARGS:
    ...    - dt_info (dict, mandatory): Dictionary containing details of NR Cells sectors.
    ...      Example:
    ...      {"SECTOR_0": {
    ...      "attached_nr_cell": "1",
    ...      "nrcellgrp_id": "0",
    ...      "lnrelgnbcell_id": "1",
    ...      "lncel_id": "1",
    ...      },
    ...      "SECTOR_1": {
    ...      "attached_nr_cell": "11",
    ...      "nrcellgrp_id": "1",
    ...      "lnrelgnbcell_id": "2",
    ...      "lncel_id": "1",
    ...      }}
    ...    - expected_nr_state (str, optional): Expected nr_state during attach ("Phone info" param). Default 5G_NSA.
    ...    - sctp_shutdown_timer (str, optional): shutdownNogNBCellTmr parameter value during test. Default 30.
    ...    - default_sctp_shutdown_timer (str, optional): shutdownNogNBCellTmr parameter default value. Default 0.
    ...    - expect_x2_link_alarms (str, optional): Expect X2 Link Alarms after locking Cell Group. Default False.
    ...    - onair_timeout (int, optional): OnAir timeout in seconds. Default 600.
    [Arguments]
    ...    ${dt_info}
    ...    ${expected_nr_state}=5G_NSA
    ...    ${sctp_shutdown_timer}=30
    ...    ${default_sctp_shutdown_timer}=0
    ...    ${expect_x2_link_alarms}=${False}
    ...    ${onair_timeout}=${600}

    gnbscf.perform_parameter_recommissioning    parameter=shutdownNogNBCellTmr
    ...    dist_name=MRBTS-{}/NRBTS-{}    operation=update    value=${sctp_shutdown_timer}

    FOR  ${sector}  IN  @{dt_info}
        ${sector_dt}=    Get From Dictionary    ${dt_info}    ${sector}
        ${attached_cell}=    Get From Dictionary    ${sector_dt}    attached_nr_cell
        ${cell_group_id}=    Get From Dictionary    ${sector_dt}    nrcellgrp_id
        data_transfer.perform_ue_attach_with_nr_state_verification
        ...    lnrelgnbcell_id=${sector_dt['lnrelgnbcell_id']}
        ...    lncel_id=${sector_dt['lncel_id']}
        ...    expected_nr_state=${expected_nr_state}
        #Block Unblock Single Cell
        gnbalarm.allow_alarm    alarm=Cell blocked
        cell_keywords.block_cell_with_status_check    cell_id=${attached_cell}    check_alarm=${True}
        Run Keyword And Expect Error    UE5GAttachException: *
        ...    data_transfer.perform_ue_attach_with_nr_state_verification
        ...    expected_nr_state=${expected_nr_state}
        cell_keywords.unblock_cell_with_status_check    cell_id=${attached_cell}    check_alarm=${True}
        Wait Until Keyword Succeeds    3x    10    data_transfer.perform_ue_attach_with_nr_state_verification
        ...    expected_nr_state=${expected_nr_state}
        #Block Unblock All Cells From Sector
        Run Keyword If    ${expect_x2_link_alarms}
        ...    Allow No X2 Link Alarms
        cell_keywords.block_cells_from_cell_group    cell_group_id=${cell_group_id}
        Run Keyword If    ${expect_x2_link_alarms}
        ...    gnbalarm.wait_for_alarm_activation    fault_id=7300    awaiting_time=${sctp_shutdown_timer}
        Run Keyword And Expect Error    UE5GAttachException: *
        ...    data_transfer.perform_ue_attach_with_nr_state_verification
        ...    expected_nr_state=${expected_nr_state}
        cell_keywords.unblock_cells_from_cell_group    cell_group_id=${cell_group_id}
        Run Keyword If    ${expect_x2_link_alarms}
        ...    Wait For OnAir And Disallow No X2 Link Alarms    onair_timeout${onair_timeout}
        gnbalarm.verify_alarm_is_not_active    fault_name=Cell blocked
        gnbalarm.disallow_alarm   alarm=Cell blocked
        Wait Until Keyword Succeeds    3x    10    data_transfer.perform_ue_attach_with_nr_state_verification
        ...    expected_nr_state=${expected_nr_state}
    END

    gnbscf.perform_parameter_recommissioning    parameter=shutdownNogNBCellTmr
    ...    dist_name=MRBTS-{}/NRBTS-{}    operation=update    value=${default_sctp_shutdown_timer}

Allow No X2 Link Alarms
    gnbalarm.allow alarm    alarm=No X2 link available
    gnbalarm.allow alarm    alarm=No X2 link available for a specific LTEENB

Wait For OnAir And Disallow No X2 Link Alarms
    [Arguments]
    ...    ${onair_timeout}=${900}
    gnbcell.wait_for_all_cells_to_be_onair    timeout=${onair_timeout}
    gnbalarm.disallow alarm    alarm=No X2 link available
    gnbalarm.disallow alarm    alarm=No X2 link available for a specific LTEENB

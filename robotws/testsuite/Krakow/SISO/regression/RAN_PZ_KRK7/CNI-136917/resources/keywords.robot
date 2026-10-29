*** Settings ***
Documentation
...    Keywords for regression testing for feature CNI-136917
...    authors: Jakub Bialon
...    group: RAN_PZ_KRK_SG_7
...    contact: jakub.bialon@nokia.com

Library    taf/rfrl/bts/devices/du/du_operations.py
Library    taf.rfrl.bts.devices.generic_bts.GenericBts    WITH NAME    genericbts
Library    taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    gnbalarms
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library    tools.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Library    taf.sbts.oam.coam.admin.interface.admin    WITH NAME    gnbadmin

*** Keywords ***
Lock Unlock SFP
    [Arguments]    ${SFP_id}
    ${bts_id}=    genericbts.get_global_bts_id
    perform_configuration_parameter_recommissioning
    ...                             dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-${SFP_id}/LANE-1
    ...                             parameter=administrativeState
    ...                             operation=update
    ...                             value=Locked
    Sleep    2min    Waiting for SFP lock
    perform_configuration_parameter_recommissioning
    ...                             dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-${SFP_id}/LANE-1
    ...                             parameter=administrativeState
    ...                             operation=update
    ...                             value=Unlocked
    Wait Until Keyword Succeeds    180 sec    5 sec   gnbcell.Verify All Cells Are Onair

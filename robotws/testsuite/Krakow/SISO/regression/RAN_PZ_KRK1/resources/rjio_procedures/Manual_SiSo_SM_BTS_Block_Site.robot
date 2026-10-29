*** Settings ***
Documentation
...    Test CB012524 - General_SiSo_Cell_block_and_unblock
...    author/contact: julia.luszcz@nokia.com


*** Keywords ***
Manual_SiSo_SM_BTS_Block_Site
    [Arguments]    ${iterations}=${1}
    Prepare Ue
    Run L3 call on all cells one by one and verify tput    sheetname_in_tput_table=Tput before Block Site
    FOR  ${iter}    IN RANGE    1    ${iterations} + 1
        gnbalarm.allow_alarm    alarm=@{allowed_alarms_during_site_block}
        gnbbbu.block_bts
        gnbalarm.wait_for_alarm_activation       fault_id=50    awaiting_time=80
        gnbcell.verify_all_cells_statuses           operational_state=disabled
        gnbbbu.unblock_bts                           timeout=600
        gnbalarm.wait_for_alarm_deactivation     fault_id=50    awaiting_time=80
        gnbalarm.disallow_alarm    alarm=@{allowed_alarms_during_site_block}
        gnbcell.wait_for_all_cells_to_be_onair      timeout=600
        Run L3 call on all cells one by one and verify tput    sheetname_in_tput_table=Iteration ${iter}
    END

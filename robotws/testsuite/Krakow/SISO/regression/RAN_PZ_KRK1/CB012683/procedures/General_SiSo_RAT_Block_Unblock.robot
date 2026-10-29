*** Settings ***
Documentation
...   Test CB012683 - General_SiSo_RAT_Block_Unblock
...   author: Julia Luszcz
...   author/contact: julia.luszcz@nokia.com


*** Keywords ***
General_SiSo_RAT_Block_Unblock
    [Arguments]    ${rat_startup_time}
    gnbcell.Verify All Cells Statuses                     operational_state=Enabled
    ...                                                   administrative_state=Unlocked
    ...                                                   usage_state=active
    gnbbbu.block_rat                                      rat=NR
    log to console    Blocked
    sleep    10s
    gnbalarm.wait_for_alarm_activation                    fault_id=4614
    ...                                                   awaiting_time=80
    gnbcell.wait_for_all_cells_statuses                   operational_state=disabled
    ...                                                   administrative_state=Unlocked
    ...                                                   usage_state=Idle
    ...                                                   timeout=${rat_startup_time}    interval=${30}
    log to console    Checked cells
    gnbbbu.unblock_rat                                    rat=NR
    gnbalarm.wait_for_alarm_deactivation                  fault_id=4614
    ...                                                   awaiting_time=80
    gnbcell.wait_for_all_cells_statuses                   operational_state=Enabled
    ...                                                   administrative_state=Unlocked
    ...                                                   usage_state=active
    ...                                                   timeout=${rat_startup_time}    interval=${30}
    Verify If All Radio Modules Online
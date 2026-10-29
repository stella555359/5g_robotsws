*** Settings ***
Documentation
...   Test CB012524 - Manual_SiSo_SM_NR_RAT_reset
...   author: Agnieszka Bylica
...   author/contact: agnieszka.bylica@nokia.com


*** Keywords ***
Manual_SiSo_SM_NR_RAT_reset
    [Arguments]    ${rat_startup_time}    ${is_actRatResetEnhancement_frozen}=${False}
    Prepare Ue

    IF    ${is_actRatResetEnhancement_frozen} == ${False}
        gnbscf.perform_bts_delta_commissioning            delta=${delta_deactivate_rat_reset_enh}
        Perform Soft NR RAT reset    rat_startup_time=${rat_startup_time}    actRatResetEnhancement=False
        Perform Hard NR RAT reset    rat_startup_time=${rat_startup_time}    actRatResetEnhancement=False
    END

    gnbscf.perform_bts_delta_commissioning             delta=${delta_activate_rat_reset_enh}
    Perform Soft NR RAT reset    rat_startup_time=${rat_startup_time}    actRatResetEnhancement=True
    Perform Hard NR RAT reset    rat_startup_time=${rat_startup_time}    actRatResetEnhancement=True


Perform Soft NR RAT reset
    [Arguments]    ${rat_startup_time}    ${actRatResetEnhancement}=False
    gnbcell.Verify All Cells Statuses                    operational_state=Enabled
    ...                                                  administrative_state=Unlocked
    ...                                                  usage_state=active
    gnbbbu.rat_reset                                      rat_type=NR
    ...                                                   reset_type=Soft
    Run Keyword If    ${actRatResetEnhancement}==False    gnbru.wait_for_all_radio_unit_statuses
    ...                                                   operational_state=disabled
    ...                                                   timeout=${60}
    ...                                                   interval=${5}
    gnbcell.wait_for_all_cells_statuses                   operational_state=Enabled
    ...                                                   administrative_state=Unlocked
    ...                                                   usage_state=active
    ...                                                   timeout=${rat_startup_time}    interval=${30}
    Run L3 call on all cells one by one and verify tput
    ...                                      sheetname_in_tput_table=after Soft NR RAT reset(${actRatResetEnhancement})

Perform Hard NR RAT reset
    [Arguments]    ${rat_startup_time}    ${actRatResetEnhancement}=False
    gnbbbu.rat_reset                                      rat_type=NR
    ...                                                   reset_type=Hard
    Run Keyword If    ${actRatResetEnhancement}==False    gnbru.wait_for_all_radio_unit_statuses
    ...                                                   operational_state=disabled
    ...                                                   timeout=${60}
    ...                                                   interval=${5}
    gnbcell.wait_for_all_cells_statuses                   operational_state=Enabled
    ...                                                   administrative_state=Unlocked
    ...                                                   usage_state=active
    ...                                                   timeout=${rat_startup_time}    interval=${30}
    Run L3 call on all cells one by one and verify tput
    ...                                       sheetname_in_tput_table=after Hard NR RAT reset(${actRatResetEnhancement})

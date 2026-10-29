*** Settings ***
Documentation
...   Test CB012683 - Manual_SiSo_SM_NR_RAT_reset
...   author: Agnieszka Bylica, Julia Luszcz
...   author/contact: agnieszka.bylica@nokia.com, julia.luszcz@nokia.com


*** Keywords ***
Manual_SiSo_SM_NR_RAT_reset
    [Arguments]    ${rat_startup_time}    ${is_actRatResetEnhancement_frozen}=${False}

    IF    ${is_actRatResetEnhancement_frozen} == ${False}
        gnbscf.perform_bts_delta_commissioning            delta=${delta_deactivate_rat_reset_enh}
        Perform Soft NR RAT reset    rat_startup_time=${rat_startup_time}    actRatResetEnhancement=false
        Perform Hard NR RAT reset    rat_startup_time=${rat_startup_time}    actRatResetEnhancement=false
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
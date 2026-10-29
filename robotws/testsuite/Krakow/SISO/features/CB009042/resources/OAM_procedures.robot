*** Settings ***
Documentation
...   Keywords implementing OAM test procedures for the feature CB009042
...   author: Agnieszka Bylica
...   contact: agnieszka.bylica@nokia.com

Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_power_reset.robot


*** Keywords ***
Block Unblock Site
    [Arguments]    ${allowed_alarms}=@{EMPTY}
    gnbalarm.allow_alarm       alarm=${allowed_alarms}
    gnbbbu.block_bts
    gnbalarm.wait_for_alarm_activation    fault_id=50
    [Teardown]    Run Keywords
    ...    gnbbbu.unblock_bts    timeout=${600}    # to adjust when bts reset is explained
    ...    AND
    ...    gnbalarm.wait_for_alarm_deactivation    fault_id=50
    ...    AND
    ...    gnbcell.wait_for_all_cells_to_be_onair    timeout=${600}
    ...    AND
    ...    gnbalarm.disallow_alarm    alarm=${allowed_alarms}

General SiSo RU module reset from GUI
    Reset All gNB Radio Units from GUI
    gnbcell.verify_all_cells_statuses    operational_state=disabled
    gnbcell.wait_for_cell_to_be_onair    timeout=${RU_startup_time} sec    interval=30 sec

General SiSo Auto RF module power reset
    [Arguments]      ${mandatory_alarms}    ${mandatory_alarms_after_power_on}=@{EMPTY}    ${allowed_alarms}=@{EMPTY}
    gnbalarm.allow_alarm       alarm=${allowed_alarms}
    General_SiSo_Auto_RF_module_power_reset.General SiSo Auto RF module power reset
    ...    mandatory_alarms=${mandatory_alarms}    mandatory_alarms_after_power_on=${mandatory_alarms_after_power_on}
    [Teardown]    gnbalarm.disallow_alarm    alarm=${allowed_alarms}

General SiSo Auto gNB Site Reset From WebUI
    [Arguments]    ${allowed_alarms}=@{EMPTY}
    gnbalarm.allow_alarm       alarm=${allowed_alarms}
    Reset gNB via GUI
    Verify gNB Does Not Respond
    gnbcell.wait_for_cell_to_be_onair    timeout=900 sec    interval=30 sec
    [Teardown]    gnbalarm.disallow_alarm    alarm=${allowed_alarms}

*** Settings ***
Documentation
...    Test CB012511 - General_SiSo_SFP_lock_unlock_for_configuration_testing
...    author/contact: agnieszka.bylica@nokia.com

Library    taf/rfrl/bts/operations.py


*** Keywords ***
General_SiSo_SFP_lock_unlock_for_configuration_testing
    [Arguments]    ${prefix_tag}
    sfp.load_delta_adding_sfp_lane        prefix_tag=${prefix_tag}
    Perform Delta Commissioning On gNB    delta=${delta_add_sfp_lane}    timeout=${300}
    Wait Until Keyword Succeeds           900 sec     30 sec    gnbcell.Verify All Cells are onAir
    sfp.load_sfp_lock_config              prefix_tag=${prefix_tag}
    gnb_alarm.Allow Alarm    alarm=${allowed_alarms_during_sfp_lock}
    FOR    ${item}    IN    &{sfp_lock_unlock_config}
        Run Keyword And Continue On Failure    sfp.lock_sfp    sfp_lock_record=${item}    reset_site=${True}
        sfp.unlock_sfp    sfp_unlock_record=${item}
    END
    gnb_alarm.Disallow Alarm    alarm=${allowed_alarms_during_sfp_lock}
    Run L3 call on all cells one by one and verify tput

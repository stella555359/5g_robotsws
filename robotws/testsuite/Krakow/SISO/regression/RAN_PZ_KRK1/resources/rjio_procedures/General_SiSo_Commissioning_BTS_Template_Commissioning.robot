*** Settings ***
Documentation
...    Test CB012511 - General_SiSo_Commissioning_BTS_Template_Commissioning
...    author/contact: agnieszka.bylica@nokia.com

Library    taf/rfrl/bts/operations.py


*** Keywords ***
General_SiSo_Commissioning_BTS_Template_Commissioning
    [Arguments]    ${prefix_tag}
    Run keywords           gnbscf.reset_configuration
    ...    AND             gnbbbu.wait_until_smod_is_online
    ...    AND             Verify the HW is in correct state
    ...    AND             gnbbbu.verify_bts_is_not_commissioned

    Log to console    Perform BTS commissioning
    Perform_bts_commissioning    prefix_tag=${prefix_tag}       wait_for_on_air_timeout=${600}           # default 300s
    ...                          asir_commissioning=${False}    skip_parameter_relation_errors=${False}
    Wait Until Keyword Succeeds     900 sec     30 sec    gnbcell.Verify All Cells are onAir
    Verify the HW is in correct state
    Verify Cell mapping
    gnbscf.verify_if_parameter_changed_to_correct_value_via_gui      dist_name=MRBTS-{}/MNL-1/MNLENT-1/SYNC-1
    ...                                                              parameter=Manual frame timing adjustment
    ...                                                              value=1
    Wait Until Keyword Succeeds     120 sec     10 sec    Verify gNB Does Not Respond    # to check the time
    Wait Until Keyword Succeeds     900 sec     30 sec    gnbcell.Verify All Cells are onAir
    gnbscf.verify_parameter_after_change    dist_name=MRBTS-{}/MNL-1/MNLENT-1/SYNC-1
    ...                                     parameter=Manual frame timing adjustment
    ...                                     value=1 (microseconds)
    Verify Param Can Be Set But Not Activated         dist_name=MRBTS-{}/NRBTS-{}/NRCELL-0
    ...                                               parameter=Maximum output power
    ...                                               value=100
    Verify Cell mapping

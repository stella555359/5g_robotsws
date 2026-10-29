*** Settings ***
Documentation
...    Test CB012511 - Manual_SiSo_CM_Commissioning_Configuration_reset
...    author/contact: agnieszka.bylica@nokia.com

Library    taf/rfrl/bts/operations.py


*** Keywords ***
Manual_SiSo_CM_Commissioning_Configuration_reset
    [Arguments]    ${prefix_tag}
    Run keywords           gnbscf.reset_configuration
    ...    AND             gnbbbu.wait_until_smod_is_online
    ...    AND             Verify the HW is in correct state
    ...    AND             gnbbbu.verify_bts_is_not_commissioned

    Log to console    Perform BTS commissioning
    Perform_bts_commissioning    prefix_tag=${prefix_tag}
    ...                          asir_commissioning=${False}    skip_parameter_relation_errors=${False}
    Wait Until Keyword Succeeds     900 sec     30 sec    gnbcell.Verify All Cells are onAir
    Verify the HW is in correct state
    gnbru.verify_all_radio_units_are_online    skip_ru_if_not_configured=${True}

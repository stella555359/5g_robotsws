*** Settings ***
Documentation
...    Test CB012524 - Manual_SiSo_STARTUP_BTS_Power_Reset
...    author/contact: agnieszka.bylica@nokia.com

Library    taf/rfrl/bts/operations.py


*** Keywords ***
Manual_SiSo_STARTUP_BTS_Power_Reset
    [Arguments]    ${prefix_tag}
    Prepare Ue
    Run keywords           gnbscf.reset_configuration
    ...    AND             gnbbbu.wait_until_smod_is_online
    ...    AND             gnbbbu.verify_statuses_on_fsm
    ...    AND             gnbbbu.verify_bts_is_not_commissioned
    FOR    ${idx}    IN RANGE    ${3}
        Log to console    Power reset iteration: ${idx}
        gnbbbu.power_reset_bts
        gnbbbu.wait_until_smod_is_online    timeout=${360}    # OM_GEN_SFS_PERF_CAP.9340
        gnbbbu.verify_statuses_on_fsm
    END

    Log to console    Perform BTS commissioning
    operations.Perform Bts Commissioning    prefix_tag=${prefix_tag}
    ...                          asir_commissioning=${False}    skip_parameter_relation_errors=${False}
    Wait Until Keyword Succeeds     900 sec     30 sec    gnbcell.Verify All Cells are onAir
    Run L3 call on all cells one by one and verify tput    sheetname_in_tput_table=After commissioning

    FOR    ${idx}    IN RANGE    ${3}
        Log to console    Power reset iteration: ${idx}
        gnbbbu.power_reset_bts
        Wait Until Keyword Succeeds     900 sec     30 sec    gnbcell.Verify All Cells are onAir
        Run L3 call on all cells one by one and verify tput    sheetname_in_tput_table=Power reset ${idx}
    END

*** Settings ***
Documentation    Suite description
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Library     CB010801.py  WITH NAME  kw
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
*** Keywords ***

Change cellBarred
    [Arguments]    ${value}    ${cell_id}=107    ${alias}=cOAM

    Log to console      Connect to cOAM change barred status.
    coam.Connect to    name=${alias}
    ${bts_info}    coam.Get bts info    connection=cOAM
    ${bts_id}     Get from dictionary    ${bts_info}    mrbtsID
    Set suite variable    ${bts_id}
    coam.Perform parameter recommissioning    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    ...                                       parameter=cellBarred
    ...                                       operation=update
    ...                                       value=${value}
    ...                                       skip_parameter_relation_errors=${True}
    ...                                       connection=${alias}
    coam.Teardown     connection=${alias}
    # Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin

Check ue mupaired
    ${output}=  kw.check_ue_mupaired
    Should Be True  ${output}

Check prb 10801 3CC
    # [Arguments]    ${s_prb}=0    ${n_prb}=273
    ${output}=  kw.check_prb_for_paired_json
    Should Be True  ${output}

Check prb 10801 4CC
    [Arguments]    ${s_prb}=0    ${n_prb}=200
    ${output}=  kw.check_prb_for_paired_json    ${s_prb}    ${n_prb}
    Should Be True  ${output}

Read counters value For 10801
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55308C34028  M55308C34029  M55118C05507  M55118C05508
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   3  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters For 10801
    log to console              Waiting for BTS Counters update 300s
    sleep   300s
    ${counters}                 Read Counters Value For 10801
    Log to console  ${counters}
    ${mumimo_paired}           get_counter_value_from_single_cell   ${counters}  501    M55308C34028
    ${mumimo_eligible}         get_counter_value_from_single_cell   ${counters}  501    M55308C34029
    ${ca_pcells}               get_counter_value_from_single_cell   ${counters}  502    M55118C05507
    ${ca_scells}               get_counter_value_from_single_cell   ${counters}  503    M55118C05508
    Should Be True      ${mumimo_paired}>=1
    Should Be True      ${mumimo_eligible}>=1
    Should Be True      ${ca_pcells}>=1
    Should Be True      ${ca_scells}>=1

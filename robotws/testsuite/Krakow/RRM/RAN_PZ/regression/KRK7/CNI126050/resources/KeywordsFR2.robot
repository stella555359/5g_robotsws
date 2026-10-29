*** Settings ***
Documentation
...    Additional robot keywords for CNI126050 FR2 part
...    authors: Lubomir Krzeminski
...    maintainer: Lubomir Krzeminski
...    group: RAN_PZ_KRK_SG_7
...    contact: lubomir.krzeminski@nokia.com

Library    Collections
Library    DateTime
Library    String
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh  WITH NAME  ssh


*** Keywords ***
Suite Precondition
    Create Directory    ${work_directory}

Cleanup after TC
    ${cell_list}    gnbcell.Get All Cells Id
    FOR     ${cell}    IN    @{cell_list}
        coam.perform_parameter_recommissioning    dist_name=${cell_dist_name}${cell}
        ...                                       parameter=${adjustPrach_name}
        ...                                       value=0
        ...                                       operation=update
        ...                                       skip_parameter_relation_errors=${True}
    END
    Wait Until Keyword Succeeds    2min    5sec     gnbcell.Verify Setup Of All Cells

Prepare before TC
    ${bts_connection}    coam.connect_to
    ${cell_list}    gnbcell.Get All Cells Id
    coam.perform_parameter_recommissioning    dist_name=${miNrRip_dist}
    ...                                       parameter=miNrRip
    ...                                       value=5min
    ...                                       operation=update
    ...                                       skip_parameter_relation_errors=${True}
    FOR     ${cell}    IN    @{cell_list}
        coam.perform_parameter_recommissioning    dist_name=${cell_dist_name}${cell}
        ...                                       parameter=pucchModeSelect
        ...                                       value=shortPucch
        ...                                       operation=update
        ...                                       skip_parameter_relation_errors=${True}
    END

Download Pm Counters
    [Arguments]    ${time_stamp}    ${bts_connection}
    ${counters}=    tools.generate_names_of_counters
    @{cell_list}    Create List    1    2
    ${counter_dic_list}=    coam.get_pm_counters
    ...                     counter_ids=${counters}
    ...                     timeout=120
    ...                     connection=${bts_connection}
    ${file_name}=    tools.find_pm_counters_by_time_stamp    ${time_stamp}    ${counter_dic_list}    ${cell_list}
    [Return]    ${file_name}

Compare pm_counters with Test Vector
    [Arguments]     ${pm_counters_path}    ${test_vector_path}     ${threshold}
    ${avg_result}    ${max_result}    tools.compare_test_vector_and_pm_counters    test_vector_path=${test_vector_path}
    ...                                                                            pm_counters_path=${pm_counters_path}
    ...                                                                            threshold=${threshold}
    ...                                                                            counters_len=${66}
    Should Be Equal    ${avg_result}    ${0}    AVG counters are above threshold!
    Should Be Equal    ${max_result}    ${0}    MAX counters are above threshold!

Test DTX Teardown
    coam.Teardown    connection=${bts_connection}

Install pandas with pip
    ${result}=    Run Process    pip install pandas    shell=True    stdout=${work_directory}pip_install_result.txt
    Log    ${result}

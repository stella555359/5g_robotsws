*** Settings ***
Documentation
...    Test suite for regression testing for feature CNI126050-FR2
...    authors: Lubomir Krzeminski, Jakub Bialon
...    maintainer: Lubomir Krzeminski
...    group: RAN_PZ_KRK_SG_7
...    contact: lubomir.krzeminski@nokia.com

Library    DateTime
Library    OperatingSystem
Library    Process
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.ue
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library    on_air_tl_preparation.testline_preparation
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    resources/KeywordsFR2.robot
Resource    resources/Variables.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup    Run Keywords    Common Suite Setup With OnAir Test Line Preparation
...                                swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                                increase_timeout_for_update_sw=1800
...                                increase_time_for_checking_radios=2100    AND
...                            Suite Precondition    AND
...                            Install pandas with pip
Suite Teardown    Common Suite Teardown


*** Test Cases ***
[1][1.0] CNI126050-02_Verification_PM_counters_for_ghost_preambles_which_lead_to_DTX_or_DTXes
    [Setup]    Run Keywords    Common Preconditions With Watching Alarms    AND
    ...                        Prepare before TC
    ${cell_list}    gnbcell.Get All Cells Id
    FOR     ${cell}    IN    @{cell_list}
        coam.perform_parameter_recommissioning    dist_name=${cell_dist_name}${cell}
        ...                                       parameter=msg1FrequencyStart
        ...                                       value=0
        ...                                       operation=update
        ...                                       skip_parameter_relation_errors=${True}
    END

    coam.perform_parameter_recommissioning    dist_name=${cell_dist_name}1
    ...                                       parameter=${adjustPrach_name}
    ...                                       value=-30
    ...                                       operation=update
    ...                                       skip_parameter_relation_errors=${True}
    FOR     ${cell}    IN    @{not_tested_cells}
        coam.perform_parameter_recommissioning    dist_name=${cell_dist_name}${cell}
        ...                                       parameter=${adjustPrach_name}
        ...                                       value=30
        ...                                       operation=update
        ...                                       skip_parameter_relation_errors=${True}
    END
    ${WEB_time_stamp}=    tools.schedule_delay    delay=3.5
    ${actNrUlRip}=    Set Variable    enabledWithoutPRACH_PUCCH_F1
    Sleep     500s     Sleeping to collect 5min counter interval and neighbour packets
    ${threshold}    Set Variable    ${5}
    ${pm_counters_path}=    KeywordsFR2.Download Pm Counters    ${WEB_time_stamp}    ${bts_connection}
    Compare pm_counters with Test Vector    ${pm_counters_path}    ${test_vector_path}     ${threshold}
    [Teardown]    Run Keywords    Cleanup after TC    AND
    ...                           Test DTX Teardown    AND
    ...                           Common Postconditions With Watching Alarms

[1][1.0] CNI126050-01_Verification_of_empty_PM_counters_without_traffic
    [Setup]    Run Keywords    Common Preconditions With Watching Alarms    AND
    ...                        Prepare before TC
    Prepare before TC
    ${cell_list}    gnbcell.Get All Cells Id
    FOR     ${cell}    IN    @{cell_list}
        coam.perform_parameter_recommissioning    dist_name=${cell_dist_name}${cell}
        ...                                       parameter=${adjustPrach_name}
        ...                                       value=30
        ...                                       operation=update
        ...                                       skip_parameter_relation_errors=${True}
    END
    # fake traffic is generated on cell 2 to check if the counters are active, without this no counter could be generated
    coam.perform_parameter_recommissioning    dist_name=${cell_dist_name}2
        ...                                       parameter=${adjustPrach_name}
        ...                                       value=-30
        ...                                       operation=update
        ...                                       skip_parameter_relation_errors=${True}
    ${WEB_time_stamp}=    tools.schedule_delay    delay=3.5
    ${actNrUlRip}=    Set Variable    enabledWithoutPRACH_PUCCH_F1
    Sleep     500s     Sleeping to collect 5min counter interval and neighbour packets
    ${pm_counters_path}=    KeywordsFR2.Download Pm Counters    ${WEB_time_stamp}    ${bts_connection}
    ${result}=    tools.verify_0_pm_counters    ${pm_counters_path}
    Should Be True    ${result}
    [Teardown]    Run Keywords    Cleanup After TC    AND
    ...                           Common Postconditions With Watching Alarms





*** Settings ***
Documentation
...
...             Test Suite authors: Agnieszka Bylica
...             Test Suite contact: agnieszka.bylica@nokia.com

Library       Collections
Library       taf.ue    WITH NAME    ue
Library       taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter    WITH NAME    gnb_pm_counter
Library       taf.rfrl.bts.devices.du.commissioning.EnbCommissioning    WITH NAME      enbscf
Library       taf/rfrl/bts/commissioning.py
Library       taf/rfrl/utilities/logger/custom_logger.py
Library       ./Resources/CounterOperations.py    WITH NAME    CounterOperations
Library       ./Resources/test_specific_keywords.py
Resource      taf/rfrl/ue/robot/REAL_UE.robot
Resource      taf/rfrl/bts/robot/gnb.robot
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables     ./Resources/variables.py


Suite Setup       Run Keywords    Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               list_of_additional_allowed_alarms=@{ADDITIONAL_ALLOWED_ALARMS}
...               prefix_tag=CB008204_1CC
...               AND
...               Perform Delta Commissioning On GNB   ${nrpmqap_delta}
...               AND
...               Change defaultLnRelGnbCellId on eNB    defaultLnRelGnbCellId_value=5
...               AND
...               REAL_UE.Prepare Ue For L3 Call    alias=UE    capabilities=REAL_UE_AB09
#Suite Setup    Run Keywords    Common Suite Setup
#...            AND    Load Default Swconfig
#...            AND    Perform Delta Commissioning On GNB   ${nrpmqap_delta}
#...            AND    Change defaultLnRelGnbCellId on eNB    defaultLnRelGnbCellId_value=5
#...            AND    REAL_UE.Prepare Ue For L3 Call    alias=UE    capabilities=REAL_UE_AB09
Suite Teardown    Run Keywords    Common Suite Teardown    AND    Perform Delta Commissioning On GNB   ${nrpmqap_delta_delete}
Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms and Restore Configuration If Test Failed


*** Variables ***
${MRBTS_ID}=    ${tl.gnbs[0].instance_id}
${NRBTS_ID}=    ${tl.gnbs[0].global_bts_id}
${COLLECT_LOGS_DURING_DATA_TRANSFER}=    ${FALSE}
${CELL_ID}      ${1}
@{ADDITIONAL_ALLOWED_ALARMS}	    Wifi Enabled Alarm

*** Test Cases ***
[1][1.0] CB008204-C-PMO-3_PM counters for monitoring time each leg for all EN-DC UEs with UL data splitting- Bearer added with UL on LTE only
        [Setup]    Run Keywords    Common Preconditions With Watching Alarms    AND
        ...        Change UL Data Path via WebEM    nsadrb_parameters_list=${nsaDrb_ulOverNr}
        gnb_pm_counter.wait_for_next_pm_period   interval=5min   delay=30
        Validate ENDC UL Counter    counter_id=M55146C00002    cell_id=${CELL_ID}
        Change UL Data Path via WebEM    nsadrb_parameters_list=${nsaDrb_ulOverLte}
        Validate ENDC UL Counter    counter_id=M55146C00001    cell_id=${CELL_ID}
        Validate ENDC UL Counter    counter_id=M55162C01001    cell_id=${CELL_ID}
        Change UL Data Path via WebEM    nsadrb_parameters_list=${nsaDrb_ulOverLteNr}
        Validate ENDC UL Counter    counter_id=M55146C00003    cell_id=${CELL_ID}
        [Teardown]    Run Keywords    Common Postconditions With Watching Alarms and Restore Configuration If Test Failed
        ...           AND    Change UL Data Path via WebEM    nsadrb_parameters_list=${nsaDrb_ulOverNr}
        ...                                                   first_execution=${False}

[1][1.0] CB008204-D-PMO-3_Counters to measure max DL UL PRB utilization
        ue.Attach UE     UE
        gnb_pm_counter.wait_for_next_pm_period   interval=5min   delay=30
        Start Data Transfer and Verify Troughput   direction=dl    duration=100s   tput=380 Mbits/sec
        gnb_pm_counter.wait_for_next_pm_period   interval=5min   delay=60
        &{dl_counters} =   CounterOperations.get_counters_dl    cell_id=${CELL_ID}
        Set Suite Variable    &{dl_counters}
        gnb_pm_counter.wait_for_next_pm_period   interval=5min   delay=30
        Start Data Transfer and Verify Troughput   direction=ul    duration=100s   tput=98 Mbits/sec
        gnb_pm_counter.wait_for_next_pm_period   interval=5min   delay=60
        &{ul_counters} =   CounterOperations.get_counters_ul    cell_id=${CELL_ID}
        Set Suite Variable    &{ul_counters}
        ue.Detach UE     UE

        Should Be Equal As Integers   ${dl_counters.M55308C36001}   100   Counter M55308C36001 should be = 100
        Should Be Equal As Integers   ${ul_counters.M55308C36002}   100   Counter M55308C36002 should be = 100

[1][1.0] CB008204-E-PMO-1_PMQAP Counters to measure DL UL used PRB and PRB utilisation
        &{counters_range} =  CounterOperations.calculate_counters_range
        ...                  dl_counters=&{dl_counters}   ul_counters=&{ul_counters}

        Should Be Equal As Integers   ${dl_counters.M55363C00003}   100   Counter M55363C00003 should be = 100
        Should Be Equal As Integers   ${ul_counters.M55363C00004}   100   Counter M55363C00004 should be = 100

        Run Keyword If
        ...        not (${counters_range.M55363C00001_min} < ${dl_counters.M55363C00001} < ${counters_range.M55363C00001_max})
        ...        Fail   Counter M55363C00001 not in expected range

        Run Keyword If
        ...        not (${counters_range.M55363C00002_min} < ${ul_counters.M55363C00002} < ${counters_range.M55363C00002_max})
        ...        Fail   Counter M55363C00002 not in expected range

*** Keywords ***
Validate ENDC UL Counter
    [Arguments]    ${counter_id}    ${cell_id}=${None}
    custom_logger.log info to console    Start validating ENDC UL counter
    clear_previous_syslog
    btslogcollector.Start collecting syslog
    Sleep    10s
    custom_logger.log info to console    Starting attach     log_hierarchy=2
    ue.Attach UE     UE
    custom_logger.log info to console    Starting data transfer verification     log_hierarchy=2
    Start Data Transfer and Verify Troughput   direction=ul    duration=100s   tput=25 Mbits/sec
    custom_logger.log info to console    Starting detach     log_hierarchy=2
    ue.Detach UE     UE
    Sleep    5s
    btslogcollector.Stop collecting syslog
    ${syslog_bearer_duration}    Run Keyword And Continue On Failure    measure_attach_time
    gnb_pm_counter.wait_for_next_pm_period   interval=5min   delay=30
    Sleep    5s
    &{ul_endc_counters} =   CounterOperations.get_counters_endc_ul    cell_id=${cell_id}
    compare_counter_to_calculated_syslog_value    ${ul_endc_counters.${counter_id}}    ${syslog_bearer_duration}
    custom_logger.log info to console    Validation completed
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'    ue.Detach UE    UE

Load Default Swconfig
    commissioning.upload_swconfig_on_classical_gnb      sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt
    Reset gNB
    Wait Until Keyword Succeeds     900 sec     15 sec    Verify Setup Of All Cells

Change defaultLnRelGnbCellId on eNB
    [Arguments]    ${defaultLnRelGnbCellId_value}
    enbscf.perform_configuration_parameter_recommissioning    dist_name=MRBTS-{}/LNBTS-{}/LNCEL-1
    ...                                                       parameter=defaultLnRelGnbCellId
    ...                                                       operation=update
    ...                                                       value=${defaultLnRelGnbCellId_value}

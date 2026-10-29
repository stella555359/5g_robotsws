*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Paulina Jedras <paulina.jedras@nokia.com>
...       - Malgorzata Konior <malgorzata.konior@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    CB010683_common_keywords.robot

*** Variables ***
&{NRPGRP_def}=            lbpsSOMethod='cell switch off'
...                       lbpsLastCellSOEnabled=False
...                       lbpsMaxLoad=10
...                       lbpsMinLoad=5
...                       lbpsRTXMaxLoad=10
...                       lbpsRTXMinLoad=5
...                       lbpsLastCellMinLoad=0
...                       lbpsLastCellRTXMinLoad=0
...                       lbpsPdcchLoadOffset=4
...                       lbpsRTXSOffTime=30
...                       lbpsRTXSOnTime=30
...                       lbpsRTXCellCapOffset=80
...                       lbpsMonWinForCellSOff=120
...                       lbpsMonWinForCellSOn=120
...                       lbpsSOffTrRule=SlidingAverageMethod
...                       lbpsSOnTrRule=SlidingAverageMethod
...                       lbpsLoadCalcMethod='Max(G, C, P)'
&{EnergySaving_FF_def}=   5GC000431=0  CB008392=0  CB008133/CB010471=0  CB008745=0  CB010683-A=0  CB010683-B=0
&{lbpsPeriodList_def}=    number_of_periods=1  period_duration=1440  suspended=0

${TX_SO}    'TX switch off'
${CELL_SO}  'cell switch off'
${MIX_SO}   'mixed switch off'

${NRPGRP-1_not_structured_params}=  ${CURDIR}/../config/yaml/NRPGRP-1_not_structured_params.yaml
${NRPGRP-1_structured_params}=  ${CURDIR}/../config/yaml/NRPGRP-1_structured_params.yaml
${NRPGRP-2_not_structured_params}=  ${CURDIR}/../config/yaml/NRPGRP-2_not_structured_params.yaml
${NRPGRP-2_structured_params}=  ${CURDIR}/../config/yaml/NRPGRP-2_structured_params.yaml
${NRBTS-1_EnergySaving_FF}=  ${CURDIR}/../config/yaml/NRBTS-1_EnergySaving_FF.yaml
${TC_cleanup}=  ${CURDIR}/../config/yaml/TC_cleanup.yaml

*** Keywords ***
Configure gNB with NRPGRPs[${nrpgpr_ids}] and Energy Saving features flags
    ${yaml_for_TC_setup}  Create list
    @{nrpgrp_ids_list}=   Split To List   ${nrpgpr_ids}
    FOR   ${id}   IN   @{nrpgrp_ids_list}
        Set NRPGRP-${id} not structured parameters
        Set NRPGRP-${id} structured parameters
        Append To List  ${yaml_for_TC_setup}  ${NRPGRP-${id}_not_structured_params}
        Append To List  ${yaml_for_TC_setup}  ${NRPGRP-${id}_structured_params}
    END
    Set Energy Saving feature flags
    Append To List  ${yaml_for_TC_setup}  ${NRBTS-1_EnergySaving_FF}
    Configure  ${yaml_for_TC_setup}

Set NRPGRP-${id:\d+} not structured parameters
    FOR    ${attribute}    IN    @{NRPGRP_def}
        ${value}    get variable value      ${NRPGRP-${id}.${attribute}}  ${NRPGRP_def['${attribute}']}
        set enb parameter value  param_path=NRPGRP-${id}.${attribute}  value=${value}  bts_id=1
    END

Set NRPGRP-${id:\d+} structured parameters
    ${lbpsCellList}         get variable value    &{NRPGRP-${id}.lbpsCellList}
    ${lbpsPeriodList}       get variable value    ${NRPGRP-${id}.lbpsperiodlist}   ${lbpsPeriodList_def}
    ${lbpsCellPeriodList}   get variable value    @{NRPGRP-${id}.lbpsCellPeriodList}

    Create yaml for NRPGRP structured parameters
    ...  yaml_path=${NRPGRP-${id}_structured_params}
    ...  nrpgrp_id=${id}
    ...  lbpscelllist=${lbpsCellList}
    ...  lbpsperiodlist=${lbpsPeriodList}
    ...  lbpscellperiodlist=${lbpsCellPeriodList}

Set Energy Saving feature flags
    FOR    ${FF}    IN    @{EnergySaving_FF_def}
        ${value}    get variable value      ${EnergySaving_FF['${FF}']}  ${EnergySaving_FF_def['${FF}']}
        set enb parameter value  param_path=${FF}  value=${value}  bts_id=1
    END

Basic cleanup
    Remove NRPGRPs and deactivate Power Saving features
    stop collecting syslog
    Detach and kill UEs from 1 to 20

Remove NRPGRPs and deactivate Power Saving features
    Configure  ${TC_cleanup}

Prepare test environment ${TC:(A_1|B_1)}
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'TX switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2  so_order=1,2  use_ext_config=0,0
    Set test variable    ${NRPGRP-2.lbpsSOMethod}             'cell switch off'
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}    True
    Set test Variable    &{NRPGRP-2.lbpsCellList}             cells=3,4  so_order=1,2  use_ext_config=0,0
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1
    Configure gNB with NRPGRPs[1,2] and Energy Saving features flags

Prepare test environment A_2
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'TX switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}           95
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}              95
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}           1
    Set test variable    ${NRPGRP-1.lbpsMinLoad}              1
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2  so_order=1,2  use_ext_config=0,0
    Set test Variable    &{EnergySaving_FF}                   CB008392=1
    Configure gNB with NRPGRPs[1] and Energy Saving features flags

Prepare test environment A_3
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'TX switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2,3,4  so_order=1,2,3,4  use_ext_config=1,1,1,0
    &{lCPL_1}=    Create Dictionary  cells=2  period_duration=1440  gap_before_period=7     method=${TX_SO}
    &{lCPL_2}=    Create Dictionary  cells=3  period_duration=5,5   gap_before_period=5,60  method=${TX_SO},${CELL_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}  ${lCPL_2}
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB010683-A=1

Prepare test environment A_4
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'cell switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    False
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2,3,4  so_order=1,2,3,4  use_ext_config=1,1,1,0
    Set test Variable    &{NRPGRP-1.lbpsPeriodList}           period_duration=5,2,1440  gap_before_period=0,3,0  suspended=0,1,0
    &{lCPL_1}=    Create Dictionary  cells=1,2,3  period_duration=1440  gap_before_period=0  method=${TX_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB010683-A=1

Prepare test environment A_5
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'TX switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2  so_order=1,2  use_ext_config=1,0
    &{lCPL_1}=    Create Dictionary  cells=1  period_duration=3,3,1440  gap_before_period=1,0,5  method=${TX_SO},${TX_SO},${CELL_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB010683-A=1

Prepare test environment A_6_B_6
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'mixed switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2,3  so_order=1,2,3  use_ext_config=1,1,0
    &{lCPL_1}=    Create Dictionary  cells=1  period_duration=1440   gap_before_period=0   method=${TX_SO}
    &{lCPL_2}=    Create Dictionary  cells=2  period_duration=1440   gap_before_period=0   method=${TX_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}  ${lCPL_2}
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB010683-A=1  CB010683-B=1

Prepare test environment A_7
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'TX switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2,3,4  so_order=1,2,3,4  use_ext_config=1,1,0,1
    &{lCPL_1}=    Create Dictionary  cells=3  period_duration=1440  gap_before_period=0  method=${CELL_SO}
    &{lCPL_2}=    Create Dictionary  cells=4  period_duration=1440,1400  gap_before_period=0,1440  method=${TX_SO},${CELL_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}  ${lCPL_2}
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB010683-A=1

Prepare test environment A_8
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'TX switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}          60
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}           60
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}           10
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}              7
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2,3,4  so_order=1,2,3,4  use_ext_config=0,0,1,0
    &{lCPL_1}=    Create Dictionary  cells=3  period_duration=1440  gap_before_period=0  method=${CELL_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB010683-A=1

Prepare test environment A_9
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'TX switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2,3,4  so_order=1,2,3,4  use_ext_config=0,0,1,0
    &{lCPL_1}=    Create Dictionary  cells=3  period_duration=1440   gap_before_period=0   method=${CELL_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}           30
    Set test Variable    ${NRPGRP-1.lbpsRTXMaxLoad}           20
    Set test Variable    ${NRPGRP-1.lbpsMaxLoad}              10
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB010683-A=1

Prepare test environment A_10
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'TX switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}           80
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}          80
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}           30
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}              90
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}           20
    Set test variable    ${NRPGRP-1.lbpsMinLoad}              2
    Set test variable    ${NRPGRP-1.lbpsLastCellMinLoad}      20
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2,3  so_order=1,2,3  use_ext_config=1,0,1
    &{lCPL_1}=    Create Dictionary  cells=1,3  period_duration=1440  gap_before_period=0  method=${CELL_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB010683-A=1

Prepare test environment A_11
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'cell switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    False
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2,3,4  so_order=1,2,100,100  use_ext_config=1,1,1,1
    &{lCPL_1}=    Create Dictionary  cells=1  period_duration=1440  gap_before_period=1440  method=${CELL_SO}
    &{lCPL_2}=    Create Dictionary  cells=2,3,4  period_duration=1440  gap_before_period=0  method=${TX_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}  &{lCPL_2}
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB010683-A=1

Prepare test environment A_12
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'cell switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    False
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2,3,4  so_order=1,2,3,4  use_ext_config=1,1,1,1
    &{lCPL_1}=    Create Dictionary  cells=1  period_duration=1440  gap_before_period=1440  method=${CELL_SO}
    &{lCPL_2}=    Create Dictionary  cells=2,3,4  period_duration=1440  gap_before_period=0  method=${TX_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}  &{lCPL_2}
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB010683-A=1

Prepare test environment A_13_B_8
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'TX switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2,3  so_order=1,2,3  use_ext_config=1,0,1
    &{lCPL_1}=    Create Dictionary  cells=1  period_duration=1440   gap_before_period=1440   method=${TX_SO}
    &{lCPL_2}=    Create Dictionary  cells=3  period_duration=1440   gap_before_period=0   method=${MIX_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}  ${lCPL_2}
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB010683-A=1  CB010683-B=1

Prepare test environment A_14_B_7
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'TX switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}           60
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}          60
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2,3  so_order=1,2,3  use_ext_config=1,1,0
    &{lCPL_1}=    Create Dictionary  cells=1  period_duration=1440  gap_before_period=0  method=${MIX_SO}
    &{lCPL_2}=    Create Dictionary  cells=2  period_duration=1440  gap_before_period=0  method=${TX_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}  ${lCPL_2}
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB010683-A=1  CB010683-B=1

Prepare test environment A_15
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'TX switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2  so_order=1,2  use_ext_config=1,0
    &{lCPL_1}=    Create Dictionary  cells=1  period_duration=1440  gap_before_period=0     method=${CELL_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}          50
    Set test variable    ${NRPGRP-1.lbpsMonWinForCellSOff}    200
    Set test variable    ${NRPGRP-1.lbpsMonWinForCellSOn}     90
    Set test variable    ${NRPGRP-1.lbpsSOffTrRule}           SlidingAverageMethod
    Set test variable    ${NRPGRP-1.lbpsSOnTrRule}            SlidingAverageMethod
    Set test variable    ${NRPGRP-1.lbpsLoadCalcMethod}       'Max(G, C, P)'
    Set test variable    ${NRPGRP-2.lbpsSOMethod}             'cell switch off'
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}    True
    Set test Variable    &{NRPGRP-2.lbpsCellList}             cells=3,4  so_order=1,2  use_ext_config=0,0
    Set test variable    ${NRPGRP-2.lbpsRTXSOffTime}          50
    Set test variable    ${NRPGRP-2.lbpsMonWinForCellSOff}    200
    Set test variable    ${NRPGRP-2.lbpsMonWinForCellSOn}     90
    Set test variable    ${NRPGRP-2.lbpsSOffTrRule}           SlidingAverageMethod
    Set test variable    ${NRPGRP-2.lbpsSOnTrRule}            SlidingAverageMethod
    Set test variable    ${NRPGRP-2.lbpsLoadCalcMethod}       'Max(G, C, P)'
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB008745=1  CB010683-A=1

Cleanup after A_16
    Detach and kill UEs from 1 to 20
    Create new plan
    Edit planned object attributes    NRBTS-1    actNrLBPowerSaving=False
    Edit planned object attributes    NRBTS-1    actNrExtCellSOMethod=False
    Edit planned object attributes    NRPGRP-1   lbpsCellList.lbpsUseExtConfig[0]=False
    Edit planned object attributes    NRPGRP-1   lbpsCellList.lbpsUseExtConfig[2]=False
    Edit planned object attributes    NRPGRP-1   lbpsSOMethod=TX switch off
    Run keyword and ignore error
    ...  Plan attribute deletion           NRPGRP-1   lbpsCellPeriodList
    Apply planned changes
    stop collecting syslog

Prepare test environment B_2
    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'TX switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}           95
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}              95
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}           1
    Set test variable    ${NRPGRP-1.lbpsMinLoad}              1
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2  so_order=1,2  use_ext_config=0,0
    Set test Variable    &{EnergySaving_FF}                   5GC000431=0  CB008392=1
    Configure gNB with NRPGRPs[1] and Energy Saving features flags

Prepare test environment B_3
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'mixed switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}          60
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}           40
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}              40
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}           20
    Set test variable    ${NRPGRP-1.lbpsMinLoad}              10
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}   10
    Set test variable    ${NRPGRP-1.lbpsLastCellMinLoad}      10
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2,3  so_order=1,100,100  use_ext_config=0,0,0
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB010683-B=1

Prepare test environment B_4
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'mixed switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}          60
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}           30
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}           15
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}              15
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}           10
    Set test variable    ${NRPGRP-1.lbpsMinLoad}              0
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}   10
    Set test variable    ${NRPGRP-1.lbpsLastCellMinLoad}      0
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2,3,4  so_order=1,100,100,100  use_ext_config=0,0,0,0
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB010683-B=1

Prepare test environment B_5
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'TX switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2  so_order=1,2  use_ext_config=0,1
    &{lCPL_1}=    Create Dictionary  cells=2  period_duration=1440  gap_before_period=0  method=${MIX_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB010683-A=1  CB010683-B=1

Prepare test environment B_9
    Change eNB parameter value  NRBTS-1.shutdownWindow  60  bts_id=1
    Set test variable    ${NRPGRP-1.lbpsSOMethod}             'cell switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}    True
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2  so_order=1,2  use_ext_config=0,0
    Set test variable    ${NRPGRP-1.lbpsMonWinForCellSOff}    200
    Set test variable    ${NRPGRP-1.lbpsMonWinForCellSOn}     200
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}          60
    Set test variable    ${NRPGRP-1.lbpsSOffTrRule}           SlidingAverageMethod
    Set test variable    ${NRPGRP-1.lbpsSOnTrRule}            SlidingAverageMethod
    Set test variable    ${NRPGRP-1.lbpsLoadCalcMethod}       'Max(G, C, P)'
    Set test variable    ${NRPGRP-2.lbpsSOMethod}             'mixed switch off'
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}    True
    Set test Variable    &{NRPGRP-2.lbpsCellList}             cells=3,4  so_order=1,2  use_ext_config=0,0
    Set test variable    ${NRPGRP-2.lbpsMonWinForCellSOff}    200
    Set test variable    ${NRPGRP-2.lbpsMonWinForCellSOn}     200
    Set test variable    ${NRPGRP-2.lbpsRTXSOffTime}          60
    Set test variable    ${NRPGRP-2.lbpsSOffTrRule}           SlidingAverageMethod
    Set test variable    ${NRPGRP-2.lbpsSOnTrRule}            SlidingAverageMethod
    Set test variable    ${NRPGRP-2.lbpsLoadCalcMethod}       'Max(G, C, P)'
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB008392=1  CB008745=1  CB010683-B=1

Cleanup after B_10
    Detach and kill UEs from 1 to 20
    Create new plan
    Edit planned object attributes    NRBTS-1    actNrLBPowerSaving=False
    Edit planned object attributes    NRBTS-1    actNrMixedSOMethod=False
    Edit planned object attributes    NRPGRP-1   lbpsSOMethod=TX switch off
    FOR  ${i}  IN RANGE  0  7
      Edit Planned Object Attributes   NRPGRP-1  lbpsPeriodList.lbpsSuspended[${i}]=notSuspended
    END
    Apply planned changes
    stop collecting syslog

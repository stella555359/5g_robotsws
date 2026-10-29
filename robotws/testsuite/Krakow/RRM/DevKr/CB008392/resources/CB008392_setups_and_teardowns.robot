*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Paulina Jedras <paulina.jedras@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    CB008392-common_keywords.robot

*** Variables ***
${1_NRPGRP_4_cell} =             ${CURDIR}/../config/yaml_config/1_NRPGRP_4_cell.yaml
${1_NRPGRP_1_cell} =             ${CURDIR}/../config/yaml_config/1_NRPGRP_1_cell.yaml
${2_NRPGRP_2_cell_per_group} =   ${CURDIR}/../config/yaml_config/2_NRPGRP_2_cell_per_group.yaml
${no_of_cells}=  4

*** Keywords ***
#All parameters which can be configured in each TC with example of use
#    Set test variable    ${NRPGRP-1.lbpsSOMethod}              'Tx switch off' or 'cell switch off'
#    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      True
#    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             60
#    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             20
#    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}            30
#    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}             30
#    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}     0
#    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            1   2   3   4
#    Set test variable    @{NRPGRP-1.nrCellId}                   1   2   3   4
#    Set test variable    ${NRPGRP-1.offset}                     10
#    Set test variable    ${NRPGRP-1.lbpsDuration}               60
#    Set test variable    ${NRPGRP-1.lbpsSuspended}              'notSuspended'
Prepare test environment CB008392-A_4_11
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             20
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             10
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}     10
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            4   3   2   1
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2   3   4
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_4_cell}  node_id=1

Prepare test environment CB008392-A_5_13
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             20
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             10
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}     10
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            4   3   2   1
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2   3   4
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      False
    Set test variable    ${NRPGRP-1.offset}                     1440
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_4_cell}  node_id=1

Prepare test environment CB008392-A_6
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             20
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             10
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}     10
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            1   2
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2
    Set NRPGRP-1 parameters
    Set test variable    ${NRPGRP-2.lbpsRTXMaxLoad}             20
    Set test variable    ${NRPGRP-2.lbpsRTXMinLoad}             10
    Set test variable    ${NRPGRP-2.lbpsLastCellRTXMinLoad}     10
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}            1   2
    Set test variable    @{NRPGRP-2.nrCellId}                   3   4
    Set test variable    ${no_of_cells}                         2
    Set NRPGRP-2 parameters
    Configure  ${2_NRPGRP_2_cell_per_group}  node_id=1

Prepare test environment CB008392-A_7
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             5
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}     5
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            1   100   100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2   3   4
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_4_cell}  node_id=1

Cleanup after test A_8
    Run keyword and ignore error   Setup X2 link between gNB2 and simulated eNB1
    Basic cleanup

Prepare test environment CB008392-A_12
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             20
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             10
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}     10
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            1
    Set test variable    @{NRPGRP-1.nrCellId}                   1
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_1_cell}  node_id=1

Prepare test environment CB008392-A_9
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            1   100   100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2   3   4
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_4_cell}  node_id=1

Prepare test environment CB008392-A_10
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            100   100   100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2   3   4
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_4_cell}  node_id=1

Prepare test environment ${TC:(A_14|A_15|A_14_15)}
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             5
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}     5
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_4_cell}  node_id=1

Prepare test environment A_16
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             5
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}     5
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_4_cell}  node_id=1

Prepare test environment A_16_E_3
    Set test variable    ${NRPGRP-1.lbpsSOMethod}               'TX switch off'
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1     2

    Set test variable    ${NRPGRP-2.lbpsSOMethod}               'cell switch off'
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}            100   100
    Set test variable    @{NRPGRP-2.nrCellId}                   3     4

    Set NRPGRP-1 parameters
    Set NRPGRP-2 parameters
    Configure  ${2_NRPGRP_2_cell_per_group}  node_id=1

Prepare test environment A_17
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             5
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}     5
#    Set test variable    ${NRPGRP-1.lbpsRTXCellCapOffset}       50
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            1   2   3   4
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2   3   4
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_4_cell}  node_id=1

Prepare test environment A_18
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             5
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}     5
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      False
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_4_cell}  node_id=1

Prepare test environment E_1_2
    Set test variable    ${NRPGRP-1.lbpsSOMethod}               'TX switch off'
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1     2
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             5
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}     5

    Set test variable    ${NRPGRP-2.lbpsSOMethod}               'cell switch off'
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}            100   100
    Set test variable    @{NRPGRP-2.nrCellId}                   3     4

    Set NRPGRP-1 parameters
    Set NRPGRP-2 parameters
    Configure  ${2_NRPGRP_2_cell_per_group}  node_id=1

Prepare test environment E_3
    Set test variable    ${NRPGRP-1.lbpsSOMethod}               'cell switch off'
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            1   2   3   4
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2   3   4
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_4_cell}  node_id=1

Cleanup after test A_10
    Run keyword if test failed    Unlock NRCELL-1
    Change eNB parameter value  NRCELL-1.pMax  26  bts_id=1
    Basic cleanup

Cleanup after test A_14
    Basic cleanup
    Run keyword and ignore error  Stop CMAS notifications for NRCELL-2

Cleanup after test A_17
    Basic cleanup
    Run keyword if test failed    Disable TX activation failure for cell-4 on RRH-4

Cleanup after test ${TC:(A_16|E_3|A_16_E_3)}
    Basic cleanup
    Execute egate command   cmd=ue_nr_rrc_setup_param id=3 establishment_cause=mo-Signalling
    Execute egate command   cmd=ue_param id=3 nr_usage_setting=data_centric
    Execute egate command   cmd=ue_nr_rrc_setup_param id=4 establishment_cause=mo-Signalling
    Execute egate command   cmd=ue_param id=4 nr_usage_setting=data_centric
    Execute egate command   cmd=qosflow_modify qos_flow=1 priority=15
    Execute egate command   cmd=qosflow_modify qos_flow=2 priority=15

Basic cleanup
    Stop collecting syslog
    Detach and kill UEs from 1 to 15
    Remove NRPGRPs and deactivate Power Saving feature

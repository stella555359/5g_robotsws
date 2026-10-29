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

Resource    ../../CB008392/resources/CB008392-common_keywords.robot

*** Variables ***
${1_NRPGRP_2_cell} =                        ${CURDIR}/../config/yaml_config/1_NRPGRP_2_cell.yaml
${1_NRPGRP_4_cells} =                       ${CURDIR}/../config/yaml_config/1_NRPGRP_4_cell.yaml
${2_NRPGRP_2_cell_per_group_5GC000431} =    ${CURDIR}/../config/yaml_config/2_NRPGRP_2_cell_per_group_5GC000431.yaml
${2_NRPGRP_2_cell_per_group_CB008392} =     ${CURDIR}/../config/yaml_config/2_NRPGRP_2_cell_per_group_CB008392.yaml
${2_NRPGRP_2_cell_and_1_cell_in_group} =    ${CURDIR}/../config/yaml_config/2_NRPGRP_2_cell_and_1_cell_in_group.yaml
${2_NRPGRP_1_cell_per_group} =              ${CURDIR}/../config/yaml_config/2_NRPGRP_1_cell_per_group.yaml

*** Keywords ***
Prepare test environment CB008133-${TC:(A_3|A_5|A_7)}
    Setup connection to admin

Prepare test environment CB008133-A_4
    Setup connection to admin
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      False
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            1   2
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_2_cell}  node_id=1

Prepare test environment CB008133-A_6
    Setup connection to admin
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             5
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            1   2
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_2_cell}  node_id=1

Prepare test environment CB008133-B-1
    Setup connection to admin
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             5
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2
    Set NRPGRP-1 parameters
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}      False
    Set test variable    ${NRPGRP-2.lbpsMaxLoad}                10
    Set test variable    ${NRPGRP-2.lbpsMinLoad}                5
    Set test variable    ${NRPGRP-2.lbpsSOMethod}               'Cell Switch Off'
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}            2   1
    Set test variable    @{NRPGRP-2.nrCellId}                   3   4
    Set NRPGRP-2 parameters
    Set test variable    ${NRBTS-1.actNrLBPowerSaving}          True
    set enb parameter value
    ...  param_path=NRPGRP-2.lbpsMaxLoad  value=${NRPGRP-2.lbpsMaxLoad}  bts_id=1
    set enb parameter value
    ...  param_path=NRPGRP-2.lbpsMinLoad  value=${NRPGRP-2.lbpsMinLoad}  bts_id=1
    set enb parameter value
    ...  param_path=NRBTS-1.actNrLBPowerSaving  value=${NRBTS-1.actNrLBPowerSaving}  bts_id=1
    Configure  ${2_NRPGRP_2_cell_per_group_5GC000431}  node_id=1

Prepare test environment CB008133-B_2
    Setup connection to admin
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             5
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            100   100   100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2   3   4
    Set NRPGRP-1 parameters
    Set test variable    ${NRBTS-1.actNrLBRTXPowerSaving}       True
    set enb parameter value
    ...  param_path=NRBTS-1.actNrLBRTXPowerSaving  value=${NRBTS-1.actNrLBRTXPowerSaving}  bts_id=1

    Configure  ${1_NRPGRP_4_cells}  node_id=1

Prepare test environment CB008133-B_3
    Setup connection to admin
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             5
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2
    Set NRPGRP-1 parameters
    Set test variable    ${NRPGRP-2.lbpsRTXMaxLoad}             10
    Set test variable    ${NRPGRP-2.lbpsRTXMinLoad}             5
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}            100   100
    Set test variable    @{NRPGRP-2.nrCellId}                   3   4
    Set NRPGRP-2 parameters
    Set test variable    ${actNrLBRTXPowerSaving}               True
    set enb parameter value
    ...  param_path=NRBTS-1.actNrLBRTXPowerSaving  value=${actNrLBRTXPowerSaving}  bts_id=1

    Configure  ${2_NRPGRP_2_cell_per_group_CB008392}  node_id=1

Prepare test environment CB008133-B_4
    Setup connection to admin
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      False
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            1   2
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2
    Set NRPGRP-1 parameters
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}            100   100
    Set test variable    @{NRPGRP-2.nrCellId}                   3   4
    Set NRPGRP-2 parameters
    Set test variable    ${actNrLBRTXPowerSaving}               True
    set enb parameter value
    ...  param_path=NRBTS-1.actNrLBRTXPowerSaving  value=${actNrLBRTXPowerSaving}  bts_id=1

    Configure  ${2_NRPGRP_2_cell_per_group_CB008392}  node_id=1

Prepare test environment CB008133-${TC:(B_5|B_6)}
    Setup connection to admin
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1   3
    Set NRPGRP-1 parameters
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}            100
    Set test variable    @{NRPGRP-2.nrCellId}                   4
    Set NRPGRP-2 parameters
    Set test variable    ${actNrLBRTXPowerSaving}               True
    Set test variable    ${actNrLBmMimoRTXPowerSaving}          True

    set enb parameter value
    ...  param_path=NRBTS-1.actNrLBRTXPowerSaving  value=${actNrLBRTXPowerSaving}  bts_id=1
    set enb parameter value
    ...  param_path=NRBTS-1.actNrLBmMimoRTXPowerSaving  value=${actNrLBmMimoRTXPowerSaving}  bts_id=1

    Configure  ${2_NRPGRP_2_cell_and_1_cell_in_group}  node_id=1

Cleanup after test A_3
    Teardown connection to admin
    Detach and kill UE16
    Detach and kill UE17
    Detach and kill UE18
    Detach and kill UE19
    Configure default NRPGRP with inactive time period

Cleanup after test A_4
    Teardown connection to admin
    Detach and kill UE1
    Configure default NRPGRP with inactive time period
    Change eNB parameter value  NRBTS-1.actNrLBmMimoRTXPowerSaving  True  bts_id=1

Cleanup after test ${TC:(A_5|A_7|B_4|B_5|B_6)}
    Teardown connection to admin
    Configure default NRPGRP with inactive time period

Cleanup after test A_6
    Execute egate command   cmd=qosflow_modify qos_flow=1 priority=15
    Execute egate command   cmd=qosflow_modify qos_flow=2 priority=15
    Execute egate command   cmd=ue_nr_rrc_setup_param id=3 establishment_cause=mo-Signalling

    Teardown connection to admin
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Configure default NRPGRP with inactive time period

Cleanup after test ${TC:(B_1|B_2|B_3)}
    Teardown connection to admin
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE11
    Detach and kill UE12
    Configure default NRPGRP with inactive time period

Configure NRPGRP CB008133-A_3
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      False
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             6
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             3
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            1   2
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_2_cell}  node_id=1

Configure NRPGRP CB008133-A_5
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}             10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}             5
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_2_cell}  node_id=1

Configure NRPGRP CB008133-A_7
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_2_cell}  node_id=1

Configure default NRPGRP with inactive time period
    Set test variable    ${NRPGRP-1.lbpsDuration}               1
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            1   2
    Set test variable    @{NRPGRP-1.nrCellId}                   1   2
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_2_cell}  node_id=1

Configure NRPGRPs with single cells [${cell_1},${cell_2}] and set CB008392 to ${CB008392:True|False} and CB008133 to ${CB008133:True|False}
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            100
    Set test variable    @{NRPGRP-1.nrCellId}                   ${cell_1}
    Set NRPGRP-1 parameters
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}            100
    Set test variable    @{NRPGRP-2.nrCellId}                   ${cell_2}
    Set NRPGRP-2 parameters
    Set test variable    ${actNrLBRTXPowerSaving}               ${CB008392}
    Set test variable    ${actNrLBmMimoRTXPowerSaving}          ${CB008133}
    set enb parameter value
    ...  param_path=NRBTS-1.actNrLBRTXPowerSaving  value=${actNrLBRTXPowerSaving}  bts_id=1
    set enb parameter value
    ...  param_path=NRBTS-1.actNrLBmMimoRTXPowerSaving  value=${actNrLBmMimoRTXPowerSaving}  bts_id=1
    Configure  ${2_NRPGRP_1_cell_per_group}  node_id=1

Configure NRPGRPs to previous state and activate CB008392
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1   3
    Set NRPGRP-1 parameters
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}            100
    Set test variable    @{NRPGRP-2.nrCellId}                   4
    Set NRPGRP-2 parameters
    Set test variable    ${actNrLBRTXPowerSaving}               True
    Set test variable    ${actNrLBmMimoRTXPowerSaving}          True

    set enb parameter value
    ...  param_path=NRBTS-1.actNrLBRTXPowerSaving  value=${actNrLBRTXPowerSaving}  bts_id=1
    set enb parameter value
    ...  param_path=NRBTS-1.actNrLBmMimoRTXPowerSaving  value=${actNrLBmMimoRTXPowerSaving}  bts_id=1

    Configure  ${2_NRPGRP_2_cell_and_1_cell_in_group}  node_id=1

Deactivate both CB008392 and CB008133
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}            100   100
    Set test variable    @{NRPGRP-1.nrCellId}                   1   3
    Set NRPGRP-1 parameters
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}      True
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}            100
    Set test variable    @{NRPGRP-2.nrCellId}                   4
    Set NRPGRP-2 parameters
    Set test variable    ${actNrLBRTXPowerSaving}               False
    Set test variable    ${actNrLBmMimoRTXPowerSaving}          False

    set enb parameter value
    ...  param_path=NRBTS-1.actNrLBRTXPowerSaving  value=${actNrLBRTXPowerSaving}  bts_id=1
    set enb parameter value
    ...  param_path=NRBTS-1.actNrLBmMimoRTXPowerSaving  value=${actNrLBmMimoRTXPowerSaving}  bts_id=1

    Configure  ${2_NRPGRP_2_cell_and_1_cell_in_group}  node_id=1


Set lbpsCellSOOrder in NRPGRP-${nrpgrp_id} to [${value}] for cells [${cell_ids}]
    @{cell_list}=   Split To List       ${cell_ids}
    @{value}=       Split To List       ${value}
    ${length_of_cell_list}=  Get length    ${cell_list}

    Create new plan
    FOR  ${i}  IN RANGE  ${length_of_cell_list}
        Edit Planned Object Attributes   NRPGRP-${nrpgrp_id}  lbpsCellList.lbpsCellSOOrder[${i}]=@{value}[${i}]
    END
    Apply planned changes

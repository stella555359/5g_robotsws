*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Konrad Bem <konrad.bem@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    configuration.robot

*** Variables ***
${NRPGRP-1_1cell} =                         ${CURDIR}/../config/yaml_config/NRPGRP-1_1cell.yaml
${NRPGRP-1_2cells} =                        ${CURDIR}/../config/yaml_config/NRPGRP-1_2cells.yaml
${NRPGRP-1_4cells} =                        ${CURDIR}/../config/yaml_config/NRPGRP-1_4cells.yaml
${NRPGRP-1_2cells_default_hardcoded} =      ${CURDIR}/../config/yaml_config/NRPGRP-1_2cells_default_hardcoded.yaml

${NRPGRP-2_1cell} =                         ${CURDIR}/../config/yaml_config/NRPGRP-2_1cell.yaml
${NRPGRP-2_2cells} =                        ${CURDIR}/../config/yaml_config/NRPGRP-2_2cells.yaml

${feature_flags} =                          ${CURDIR}/../config/yaml_config/feature_flags.yaml

*** Keywords ***
Prepare test environment CB010471-${TC:(A_2|A_4|A_7)}
    Configure default NRPGRP-1 with inactive time period

Prepare test environment CB010471-A_3
    # CB008392
    Set test variable    ${NRBTS-1.actNrLBRTXPowerSaving}           False
    # 5GC000431
    Set test variable    ${NRBTS-1.actNrLBPowerSaving}              False
    # CB008133 - 64TRX, CB010471 - 32TRX
    Set test variable    ${NRBTS-1.actNrLBmMimoRTXPowerSaving}      True

    Set test variable    ${NRPGRP-1.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}                 5
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-1.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}         0
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                1
    Set test variable    @{NRPGRP-1.nrCellId}                       1
    Set test variable    ${NRPGRP-1.offset}                         0
    Set test variable    ${NRPGRP-1.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-1.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-1.lbpsMinLoad}                    20

    Set test variable    ${NRPGRP-2.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-2.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-2.lbpsRTXMinLoad}                 5
    Set test variable    ${NRPGRP-2.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-2.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-2.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-2.lbpsLastCellRTXMinLoad}         0
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}                2
    Set test variable    @{NRPGRP-2.nrCellId}                       2
    Set test variable    ${NRPGRP-2.offset}                         0
    Set test variable    ${NRPGRP-2.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-2.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-2.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-2.lbpsMinLoad}                    20

    Set NRPGRP-1 parameters
    Set NRPGRP-2 parameters

    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${NRPGRP-1_1cell}     ${NRPGRP-2_1cell}     ${feature_flags}
    Configure    ${yaml_paths_to_configure}  node_id=1


Prepare test environment CB010471-A_5
    # CB008392
    Set test variable    ${NRBTS-1.actNrLBRTXPowerSaving}           False
    # 5GC000431
    Set test variable    ${NRBTS-1.actNrLBPowerSaving}              False
    # CB008133 - 64TRX, CB010471 - 32TRX
    Set test variable    ${NRBTS-1.actNrLBmMimoRTXPowerSaving}      True

    Set test variable    ${NRPGRP-1.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}                 5
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-1.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}         0
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                1   2
    Set test variable    @{NRPGRP-1.nrCellId}                       1   2
    Set test variable    ${NRPGRP-1.offset}                         0
    Set test variable    ${NRPGRP-1.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-1.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-1.lbpsMinLoad}                    20

    Set NRPGRP-1 parameters
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${NRPGRP-1_2cells}      ${feature_flags}
    Configure    ${yaml_paths_to_configure}  node_id=1


Prepare test environment CB010471-B_1
    # CB008392
    Set test variable    ${NRBTS-1.actNrLBRTXPowerSaving}           False
    # 5GC000431
    Set test variable    ${NRBTS-1.actNrLBPowerSaving}              True
    # CB008133 - 64TRX, CB010471 - 32TRX
    Set test variable    ${NRBTS-1.actNrLBmMimoRTXPowerSaving}      True

    Set test variable    ${NRPGRP-1.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}                 5
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-1.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}         0
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                100   100
    Set test variable    @{NRPGRP-1.nrCellId}                       1   2
    Set test variable    ${NRPGRP-1.offset}                         0
    Set test variable    ${NRPGRP-1.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-1.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-1.lbpsMinLoad}                    20

    Set test variable    ${NRPGRP-2.lbpsSOMethod}                   'Cell Switch Off'
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}          False
    Set test variable    ${NRPGRP-2.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-2.lbpsRTXMinLoad}                 5
    Set test variable    ${NRPGRP-2.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-2.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-2.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-2.lbpsLastCellRTXMinLoad}         0
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}                2   1
    Set test variable    @{NRPGRP-2.nrCellId}                       3   4
    Set test variable    ${NRPGRP-2.offset}                         0
    Set test variable    ${NRPGRP-2.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-2.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-2.lbpsMaxLoad}                    10
    Set test variable    ${NRPGRP-2.lbpsMinLoad}                    5

    Set NRPGRP-1 parameters
    Set NRPGRP-2 parameters

    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${NRPGRP-1_2cells}     ${NRPGRP-2_2cells}       ${feature_flags}
    Configure    ${yaml_paths_to_configure}  node_id=1


Prepare test environment CB010471-B_2
    # CB008392
    Set test variable    ${NRBTS-1.actNrLBRTXPowerSaving}           True
    # 5GC000431
    Set test variable    ${NRBTS-1.actNrLBPowerSaving}              False
    # CB008133 - 64TRX, CB010471 - 32TRX
    Set test variable    ${NRBTS-1.actNrLBmMimoRTXPowerSaving}      True

    Set test variable    ${NRPGRP-1.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}                 5
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-1.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}         0
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                100   100   100   100
    Set test variable    @{NRPGRP-1.nrCellId}                       1   2   3   4
    Set test variable    ${NRPGRP-1.offset}                         0
    Set test variable    ${NRPGRP-1.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-1.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-1.lbpsMinLoad}                    20

    Set NRPGRP-1 parameters
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${NRPGRP-1_4cells}      ${feature_flags}
    Configure    ${yaml_paths_to_configure}  node_id=1


Prepare test environment CB010471-B_3
    # CB008392
    Set test variable    ${NRBTS-1.actNrLBRTXPowerSaving}           True
    # 5GC000431
    Set test variable    ${NRBTS-1.actNrLBPowerSaving}              False
    # CB008133 - 64TRX, CB010471 - 32TRX
    Set test variable    ${NRBTS-1.actNrLBmMimoRTXPowerSaving}      True

    Set test variable    ${NRPGRP-1.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}                 5
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-1.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}         0
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                100   100
    Set test variable    @{NRPGRP-1.nrCellId}                       1   2
    Set test variable    ${NRPGRP-1.offset}                         0
    Set test variable    ${NRPGRP-1.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-1.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-1.lbpsMinLoad}                    20

    Set test variable    ${NRPGRP-2.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-2.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-2.lbpsRTXMinLoad}                 5
    Set test variable    ${NRPGRP-2.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-2.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-2.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-2.lbpsLastCellRTXMinLoad}         0
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}                100   100
    Set test variable    @{NRPGRP-2.nrCellId}                       3   4
    Set test variable    ${NRPGRP-2.offset}                         0
    Set test variable    ${NRPGRP-2.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-2.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-2.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-2.lbpsMinLoad}                    20

    Set NRPGRP-1 parameters
    Set NRPGRP-2 parameters
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${NRPGRP-1_2cells}     ${NRPGRP-2_2cells}       ${feature_flags}
    Configure    ${yaml_paths_to_configure}  node_id=1


Prepare test environment CB010471-B_4
    # CB008392
    Set test variable    ${NRBTS-1.actNrLBRTXPowerSaving}           True
    # 5GC000431
    Set test variable    ${NRBTS-1.actNrLBPowerSaving}              False
    # CB008133 - 64TRX, CB010471 - 32TRX
    Set test variable    ${NRBTS-1.actNrLBmMimoRTXPowerSaving}      True

    Set test variable    ${NRPGRP-1.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}                 5
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-1.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}         0
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                1
    Set test variable    @{NRPGRP-1.nrCellId}                       1
    Set test variable    ${NRPGRP-1.offset}                         0
    Set test variable    ${NRPGRP-1.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-1.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-1.lbpsMinLoad}                    20

    Set test variable    ${NRPGRP-2.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-2.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-2.lbpsRTXMinLoad}                 5
    Set test variable    ${NRPGRP-2.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-2.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-2.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-2.lbpsLastCellRTXMinLoad}         0
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}                100   100
    Set test variable    @{NRPGRP-2.nrCellId}                       3   4
    Set test variable    ${NRPGRP-2.offset}                         0
    Set test variable    ${NRPGRP-2.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-2.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-2.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-2.lbpsMinLoad}                    20

    Set NRPGRP-1 parameters
    Set NRPGRP-2 parameters

    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${NRPGRP-1_1cell}     ${NRPGRP-2_2cells}       ${feature_flags}
    Configure    ${yaml_paths_to_configure}    node_id=1


Prepare test environment CB010471-${TC:(B_5|B_6)}
    # CB008392
    Set test variable    ${NRBTS-1.actNrLBRTXPowerSaving}           True
    # 5GC000431
    Set test variable    ${NRBTS-1.actNrLBPowerSaving}              False
    # CB008133 - 64TRX, CB010471 - 32TRX
    Set test variable    ${NRBTS-1.actNrLBmMimoRTXPowerSaving}      True

    Set test variable    ${NRPGRP-1.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}                 5
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-1.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}         0
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                100   100
    Set test variable    @{NRPGRP-1.nrCellId}                       1   3
    Set test variable    ${NRPGRP-1.offset}                         0
    Set test variable    ${NRPGRP-1.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-1.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-1.lbpsMinLoad}                    20

    Set test variable    ${NRPGRP-2.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-2.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-2.lbpsRTXMinLoad}                 5
    Set test variable    ${NRPGRP-2.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-2.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-2.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-2.lbpsLastCellRTXMinLoad}         0
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}                1
    Set test variable    @{NRPGRP-2.nrCellId}                       4
    Set test variable    ${NRPGRP-2.offset}                         0
    Set test variable    ${NRPGRP-2.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-2.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-2.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-2.lbpsMinLoad}                    20
    Set NRPGRP-1 parameters
    Set NRPGRP-2 parameters

    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${NRPGRP-1_2cells}     ${NRPGRP-2_1cell}        ${feature_flags}
    Configure    ${yaml_paths_to_configure}    node_id=1


Prepare test environment CB010471-B_7
    # CB008392
    Set test variable    ${NRBTS-1.actNrLBRTXPowerSaving}           False
    # 5GC000431
    Set test variable    ${NRBTS-1.actNrLBPowerSaving}              False
    # CB008133 - 64TRX, CB010471 - 32TRX
    Set test variable    ${NRBTS-1.actNrLBmMimoRTXPowerSaving}      True

    Set test variable    ${NRPGRP-1.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}                 6
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}                 3
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-1.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}         0
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                100   100   100   100
    Set test variable    @{NRPGRP-1.nrCellId}                       1   2   3   4
    Set test variable    ${NRPGRP-1.offset}                         0
    Set test variable    ${NRPGRP-1.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-1.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-1.lbpsMinLoad}                    20

    Set NRPGRP-1 parameters
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${NRPGRP-1_4cells}      ${feature_flags}
    Configure    ${yaml_paths_to_configure}  node_id=1

Prepare test environment CB010471-B_8
    # CB008392
    Set test variable    ${NRBTS-1.actNrLBRTXPowerSaving}           False
    # 5GC000431
    Set test variable    ${NRBTS-1.actNrLBPowerSaving}              False
    # CB008133 - 64TRX, CB010471 - 32TRX
    Set test variable    ${NRBTS-1.actNrLBmMimoRTXPowerSaving}      True

    Set test variable    ${NRPGRP-1.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}                 6
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}                 3
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-1.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}         0
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                100   100
    Set test variable    @{NRPGRP-1.nrCellId}                       1   2
    Set test variable    ${NRPGRP-1.offset}                         0
    Set test variable    ${NRPGRP-1.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-1.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-1.lbpsMinLoad}                    20

    Set test variable    ${NRPGRP-2.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-2.lbpsRTXMaxLoad}                 6
    Set test variable    ${NRPGRP-2.lbpsRTXMinLoad}                 3
    Set test variable    ${NRPGRP-2.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-2.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-2.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-2.lbpsLastCellRTXMinLoad}         0
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}                100   100
    Set test variable    @{NRPGRP-2.nrCellId}                       3   4
    Set test variable    ${NRPGRP-2.offset}                         0
    Set test variable    ${NRPGRP-2.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-2.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-2.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-2.lbpsMinLoad}                    20

    Set NRPGRP-1 parameters
    Set NRPGRP-2 parameters

    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${NRPGRP-1_2cells}     ${NRPGRP-2_2cells}       ${feature_flags}
    Configure    ${yaml_paths_to_configure}  node_id=1

Prepare test environment CB010471-Robustness_${TC:(1|3)}
    # CB008392
    Set test variable    ${NRBTS-1.actNrLBRTXPowerSaving}           False
    # 5GC000431
    Set test variable    ${NRBTS-1.actNrLBPowerSaving}              False
    # CB008133 - 64TRX, CB010471 - 32TRX
    Set test variable    ${NRBTS-1.actNrLBmMimoRTXPowerSaving}      True

    Set test variable    ${NRPGRP-1.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}                 20
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}                 15
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-1.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}         15
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                100   100   100   100
    Set test variable    @{NRPGRP-1.nrCellId}                       1   2   3   4
    Set test variable    ${NRPGRP-1.offset}                         0
    Set test variable    ${NRPGRP-1.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-1.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-1.lbpsMinLoad}                    20

    Set NRPGRP-1 parameters
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${NRPGRP-1_4cells}      ${feature_flags}
    Configure    ${yaml_paths_to_configure}  node_id=1


Prepare test environment CB010471-Robustness_2
    # CB008392
    Set test variable    ${NRBTS-1.actNrLBRTXPowerSaving}           False
    # 5GC000431
    Set test variable    ${NRBTS-1.actNrLBPowerSaving}              False
    # CB008133 - 64TRX, CB010471 - 32TRX
    Set test variable    ${NRBTS-1.actNrLBmMimoRTXPowerSaving}      True

    Set test variable    ${NRPGRP-1.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}                 5
    Set test variable    ${NRPGRP-1.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-1.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-1.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-1.lbpsLastCellRTXMinLoad}         5
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                100   100
    Set test variable    @{NRPGRP-1.nrCellId}                       1   3
    Set test variable    ${NRPGRP-1.offset}                         0
    Set test variable    ${NRPGRP-1.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-1.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-1.lbpsMinLoad}                    20

    Set test variable    ${NRPGRP-2.lbpsSOMethod}                   'Tx switch off'
    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-2.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-2.lbpsRTXMinLoad}                 5
    Set test variable    ${NRPGRP-2.lbpsRTXSOffTime}                30
    Set test variable    ${NRPGRP-2.lbpsRTXSOnTime}                 30
    Set test variable    ${NRPGRP-2.lbpsRTXCellCapOffset}           80
    Set test variable    ${NRPGRP-2.lbpsLastCellRTXMinLoad}         5
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}                100   100
    Set test variable    @{NRPGRP-2.nrCellId}                       2   4
    Set test variable    ${NRPGRP-2.offset}                         0
    Set test variable    ${NRPGRP-2.lbpsDuration}                   1440
    Set test variable    ${NRPGRP-2.lbpsSuspended}                  'notSuspended'
    # 5GC000431 specific parameters
    Set test variable    ${NRPGRP-2.lbpsMaxLoad}                    60
    Set test variable    ${NRPGRP-2.lbpsMinLoad}                    20

    Set NRPGRP-1 parameters
    Set NRPGRP-2 parameters
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${NRPGRP-1_2cells}     ${NRPGRP-2_2cells}       ${feature_flags}
    Configure    ${yaml_paths_to_configure}  node_id=1


Cleanup after test CB010471-A_2
    Detach and kill UE16
    Detach and kill UE17
    Detach and kill UE18
    Detach and kill UE19
    Configure default NRPGRP-1 with inactive time period


Cleanup after test CB010471-A_3
    Detach and kill UE1
    Detach and kill UE2
    Configure default NRPGRP-1 with inactive time period


Cleanup after test CB010471-${TC:(A_4|A_7|B_4|B_5|B_6)}
    Configure default NRPGRP-1 with inactive time period


Cleanup after test CB010471-A_5
    Execute egate command   cmd=qosflow_modify qos_flow=1 priority=15
    Execute egate command   cmd=qosflow_modify qos_flow=2 priority=15
    Execute egate command   cmd=ue_nr_rrc_setup_param id=3 establishment_cause=mo-Signalling

    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Configure default NRPGRP-1 with inactive time period


Cleanup after test CB010471-${TC:(B_2|B_3)}
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE11
    Detach and kill UE12
    Configure default NRPGRP-1 with inactive time period


Cleanup after test CB010471-${TC:(B_1|B_7|B_8)}
    Detach and kill UEs from 1 to 4
    Configure default NRPGRP-1 with inactive time period


Cleanup after test CB010471-Robustness_1
    Detach and kill UEs from 1 to 8
    Configure default NRPGRP-1 with inactive time period


Cleanup after test CB010471-Robustness_2
    Detach and kill UEs from 1 to 4
    Unlock NRCELL-1
    Unlock NRCELL-2
    Unlock NRCELL-3
    Unlock NRCELL-4
    Configure default NRPGRP-1 with inactive time period


Cleanup after test CB010471-Robustness_3
    Configure default NRPGRP-1 with inactive time period


Configure NRPGRP-1 for CB010471-A_2
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          False
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}                 6
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}                 3
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                1   2
    Set test variable    @{NRPGRP-1.nrCellId}                       1   2
    Set NRPGRP-1 parameters
    Configure  ${NRPGRP-1_2cells}  node_id=1


Configure NRPGRP-1 for CB010471-A_4
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}                 5
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                100   100
    Set test variable    @{NRPGRP-1.nrCellId}                       1   2
    Set NRPGRP-1 parameters
    Configure  ${NRPGRP-1_2cells}  node_id=1


Configure NRPGRP-1 for CB010471-A_7
    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    ${NRPGRP-1.lbpsRTXMaxLoad}                 10
    Set test variable    ${NRPGRP-1.lbpsRTXMinLoad}                 5
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                100   100
    Set test variable    @{NRPGRP-1.nrCellId}                       1   2
    Set NRPGRP-1 parameters
    Configure  ${NRPGRP-1_2cells}  node_id=1


Configure default NRPGRP-1 with inactive time period
    Configure  ${NRPGRP-1_2cells_default_hardcoded}  node_id=1


Configure NRPGRPs with single cells [${cell_1},${cell_2}] and set CB008392 to ${CB008392:True|False} and CB010471 to ${CB010471:True|False}
    # CB008392
    Set test variable    ${NRBTS-1.actNrLBRTXPowerSaving}           ${CB008392}
    # CB008133 - 64TRX, CB010471 - 32TRX
    Set test variable    ${NRBTS-1.actNrLBmMimoRTXPowerSaving}      ${CB010471}

    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                100
    Set test variable    @{NRPGRP-1.nrCellId}                       ${cell_1}

    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}          True
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}                100
    Set test variable    @{NRPGRP-2.nrCellId}                       ${cell_2}

    Set NRPGRP-1 parameters
    Set NRPGRP-2 parameters
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${NRPGRP-1_1cell}     ${NRPGRP-2_1cell}     ${feature_flags}
    Configure    ${yaml_paths_to_configure}  node_id=1


Configure NRPGRPs to previous state and activate CB008392
    # CB008392
    Set test variable    ${NRBTS-1.actNrLBRTXPowerSaving}           True
    # CB008133 - 64TRX, CB010471 - 32TRX
    Set test variable    ${NRBTS-1.actNrLBmMimoRTXPowerSaving}      True

    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                100   100
    Set test variable    @{NRPGRP-1.nrCellId}                       1   3

    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}          True
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}                100
    Set test variable    @{NRPGRP-2.nrCellId}                       4

    Set NRPGRP-1 parameters
    Set NRPGRP-2 parameters

    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${NRPGRP-1_2cells}     ${NRPGRP-2_1cell}    ${feature_flags}
    Configure    ${yaml_paths_to_configure}  node_id=1


Deactivate both CB008392 and CB010471
    # CB008392
    Set test variable    ${NRBTS-1.actNrLBRTXPowerSaving}           False
    # CB008133 - 64TRX, CB010471 - 32TRX
    Set test variable    ${NRBTS-1.actNrLBmMimoRTXPowerSaving}      False

    Set test variable    ${NRPGRP-1.lbpsLastCellSOEnabled}          True
    Set test variable    @{NRPGRP-1.lbpsCellSOOrder}                100   100
    Set test variable    @{NRPGRP-1.nrCellId}                       1   3

    Set test variable    ${NRPGRP-2.lbpsLastCellSOEnabled}          True
    Set test variable    @{NRPGRP-2.lbpsCellSOOrder}                100
    Set test variable    @{NRPGRP-2.nrCellId}                       4

    Set NRPGRP-1 parameters
    Set NRPGRP-2 parameters

    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${NRPGRP-1_2cells}     ${NRPGRP-2_1cell}      ${feature_flags}
    Configure    ${yaml_paths_to_configure}  node_id=1
